<?php

declare(strict_types=1);

if (!defined('_PS_VERSION_')) {
    exit;
}

class Opcache_Monitor extends Module
{
    public function __construct()
    {
        $this->name = 'opcache_monitor';
        $this->tab = 'administration';
        $this->version = '1.0.0';
        $this->author = 'HADNET';
        $this->need_instance = 0;
        $this->ps_versions_compliancy = [
            'min' => '9.0.0',
            'max' => _PS_VERSION_,
        ];
        $this->bootstrap = true;

        parent::__construct();

        $this->displayName = $this->trans('OPcache Monitor', [], 'Modules.Opcachemonitor.Admin');
        $this->description = $this->trans(
            'Displays detailed OPcache statistics and configuration in the Back Office dashboard.',
            [],
            'Modules.Opcachemonitor.Admin'
        );
    }

    public function install(): bool
    {
        return parent::install()
            && $this->registerHook('dashboardZoneOne')
            && $this->registerHook('actionAdminControllerSetMedia');
    }

    public function uninstall(): bool
    {
        return parent::uninstall();
    }

    /**
     * Hook: dashboard widget
     */
    public function hookDashboardZoneOne(): string
    {
        if (!function_exists('opcache_get_status')) {
            return $this->renderNotAvailable('OPcache extension is not installed.');
        }

        $status = opcache_get_status(false);
        $config = opcache_get_configuration();

        if ($status === false) {
            return $this->renderNotAvailable('OPcache is disabled.');
        }

        $this->context->smarty->assign([
            'opcache_enabled'       => $status['opcache_enabled'] ?? false,
            'cache_full'            => $status['cache_full'] ?? false,
            'restart_pending'       => $status['restart_pending'] ?? false,
            'restart_in_progress'   => $status['restart_in_progress'] ?? false,

            // Memory
            'memory_usage'          => $status['memory_usage'] ?? [],
            'memory_used_mb'        => round(($status['memory_usage']['used_memory'] ?? 0) / 1024 / 1024, 2),
            'memory_free_mb'        => round(($status['memory_usage']['free_memory'] ?? 0) / 1024 / 1024, 2),
            'memory_wasted_mb'      => round(($status['memory_usage']['wasted_memory'] ?? 0) / 1024 / 1024, 2),
            'memory_total_mb'       => round((
                    ($status['memory_usage']['used_memory'] ?? 0) +
                    ($status['memory_usage']['free_memory'] ?? 0) +
                    ($status['memory_usage']['wasted_memory'] ?? 0)
                ) / 1024 / 1024, 2),
            'memory_usage_pct'      => $status['memory_usage']['current_wasted_percentage'] ?? 0,

            // Interned strings
            'interned_strings'      => $status['interned_strings_usage'] ?? [],

            // Statistics
            'opcache_statistics'    => $status['opcache_statistics'] ?? [],
            'hit_rate'              => round($status['opcache_statistics']['opcache_hit_rate'] ?? 0, 2),

            // JIT (PHP 8+)
            'jit'                   => $status['jit'] ?? null,

            // Configuration
            'directives'            => $config['directives'] ?? [],
            'version'               => $config['version'] ?? [],

            // Reset URL
            'reset_url'             => $this->context->link->getAdminLink('AdminModules') . '&configure=' . $this->name . '&opcache_reset=1',
        ]);

        return $this->display(__FILE__, 'views/templates/hook/dashboard.tpl');
    }

    /**
     * Add CSS to BO
     */
    public function hookActionAdminControllerSetMedia(): void
    {
        $this->context->controller->addCSS($this->_path . 'views/css/opcache_monitor.css');
    }

    /**
     * Configuration page - handle reset + show stats page
     */
    public function getContent(): string
    {
        $output = '';

        if (Tools::getValue('opcache_reset')) {
            if (function_exists('opcache_reset')) {
                opcache_reset();
                $output .= $this->displayConfirmation(
                    $this->trans('OPcache has been reset successfully.', [], 'Modules.Opcachemonitor.Admin')
                );
            }
        }

        if (!function_exists('opcache_get_status')) {
            return $output . $this->renderNotAvailable('OPcache extension is not installed.');
        }

        $status = opcache_get_status(true); // true = include scripts
        $config = opcache_get_configuration();

        $scripts = [];
        if (isset($status['scripts'])) {
            foreach ($status['scripts'] as $path => $info) {
                $scripts[] = [
                    'path'          => str_replace(_PS_ROOT_DIR_, '', $path),
                    'hits'          => $info['hits'],
                    'memory'        => round($info['memory_consumption'] / 1024, 2),
                    'last_used'     => date('Y-m-d H:i:s', $info['last_used_timestamp']),
                    'revalidate'    => date('Y-m-d H:i:s', $info['revalidate']),
                ];
            }
            usort($scripts, fn($a, $b) => $b['hits'] <=> $a['hits']);
        }

        $memoryUsed   = ($status['memory_usage']['used_memory'] ?? 0);
        $memoryFree   = ($status['memory_usage']['free_memory'] ?? 0);
        $memoryWasted = ($status['memory_usage']['wasted_memory'] ?? 0);
        $memoryTotal  = $memoryUsed + $memoryFree + $memoryWasted;

        // Recommendations per directive: [dev, prod, description]
        $recommendations = [
            'opcache.enable'                  => [1,         1,         'Must be enabled'],
            'opcache.enable_cli'              => [0,         0,         'Enable for CLI scripts if needed'],
            'opcache.memory_consumption'      => [128,       256,       'MB of shared memory. Increase if cache_full=true'],
            'opcache.interned_strings_buffer' => [8,         16,        'MB for interned strings. Increase for large apps'],
            'opcache.max_accelerated_files'   => [10000,     20000,     'Max cached files. run: find . -name "*.php" | wc -l'],
            'opcache.revalidate_freq'         => [2,         0,         'Seconds between file change checks. 0=never (prod)'],
            'opcache.validate_timestamps'     => [1,         0,         'Disable on prod for max performance'],
            'opcache.save_comments'           => [1,         1,         'Required by Doctrine/Annotations'],
            'opcache.fast_shutdown'           => [1,         1,         'Faster shutdown sequence'],
            'opcache.max_wasted_percentage'   => [5,         5,         'Trigger restart when wasted % exceeds this'],
            'opcache.consistency_checks'      => [0,         0,         'Checksums on each access - big performance hit'],
            'opcache.huge_code_pages'         => [0,         1,         'Use huge pages for better TLB performance (Linux)'],
            'opcache.jit'                     => ['tracing', 'tracing', 'JIT mode: off/function/tracing'],
            'opcache.jit_buffer_size'         => [64,        128,       'MB for JIT compiled code'],
        ];

        $this->context->smarty->assign([
            'opcache_enabled'       => $status['opcache_enabled'] ?? false,
            'cache_full'            => $status['cache_full'] ?? false,
            'memory_used_mb'        => round($memoryUsed / 1024 / 1024, 2),
            'memory_free_mb'        => round($memoryFree / 1024 / 1024, 2),
            'memory_wasted_mb'      => round($memoryWasted / 1024 / 1024, 2),
            'memory_total_mb'       => round($memoryTotal / 1024 / 1024, 2),
            'memory_used_pct'       => $memoryTotal > 0 ? round($memoryUsed / $memoryTotal * 100, 1) : 0,
            'interned_strings'      => $status['interned_strings_usage'] ?? [],
            'opcache_statistics'    => $status['opcache_statistics'] ?? [],
            'hit_rate'              => round($status['opcache_statistics']['opcache_hit_rate'] ?? 0, 2),
            'jit'                   => $status['jit'] ?? null,
            'directives'            => $config['directives'] ?? [],
            'recommendations'       => $recommendations,
            'version'               => $config['version'] ?? [],
            'scripts'               => array_slice($scripts, 0, 100),
            'scripts_total'         => count($scripts),
            'reset_url'             => $this->context->link->getAdminLink('AdminModules') . '&configure=' . $this->name . '&opcache_reset=1',
            'form_action'           => $this->context->link->getAdminLink('AdminModules') . '&configure=' . $this->name,
        ]);

        return $output . $this->display(__FILE__, 'views/templates/admin/configure.tpl');
    }

    private function renderNotAvailable(string $message): string
    {
        $this->context->smarty->assign(['opcache_unavailable_message' => $message]);
        return $this->display(__FILE__, 'views/templates/admin/unavailable.tpl');
    }
}
