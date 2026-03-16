{**
 * OPcache Monitor - Dashboard widget
 *}
<div class="opcache-monitor-widget panel">
  <div class="panel-heading">
    <i class="icon-bolt"></i>
    OPcache Monitor
    {if $opcache_enabled}
      <span class="badge badge-success">ON</span>
    {else}
      <span class="badge badge-danger">OFF</span>
    {/if}
    {if $cache_full}
      <span class="badge badge-warning">CACHE FULL</span>
    {/if}
    <a href="{$reset_url|escape:'html':'UTF-8'}" class="btn btn-default btn-xs pull-right">
      <i class="icon-refresh"></i> Reset
    </a>
  </div>

  {if $opcache_enabled}
  <div class="panel-body">

    {* Hit rate *}
    <div class="opcache-hit-rate">
      <div class="hit-rate-label">Hit Rate</div>
      <div class="hit-rate-value {if $hit_rate >= 90}good{elseif $hit_rate >= 70}warning{else}bad{/if}">
        {$hit_rate}%
      </div>
      <div class="progress">
        <div class="progress-bar {if $hit_rate >= 90}progress-bar-success{elseif $hit_rate >= 70}progress-bar-warning{else}progress-bar-danger{/if}"
             style="width: {$hit_rate}%"></div>
      </div>
    </div>

    {* Memory *}
    <div class="opcache-section">
      <h4>Memory</h4>
      <div class="row">
        <div class="col-xs-4 text-center">
          <div class="opcache-stat-value text-success">{$memory_used_mb} MB</div>
          <div class="opcache-stat-label">Used</div>
        </div>
        <div class="col-xs-4 text-center">
          <div class="opcache-stat-value text-info">{$memory_free_mb} MB</div>
          <div class="opcache-stat-label">Free</div>
        </div>
        <div class="col-xs-4 text-center">
          <div class="opcache-stat-value text-warning">{$memory_wasted_mb} MB</div>
          <div class="opcache-stat-label">Wasted</div>
        </div>
      </div>
    </div>

    {* Statistics *}
    {if $opcache_statistics}
    <div class="opcache-section">
      <h4>Statistics</h4>
      <table class="table table-condensed">
        <tr><td>Cached scripts</td><td><strong>{$opcache_statistics.num_cached_scripts}</strong></td></tr>
        <tr><td>Cached keys</td><td><strong>{$opcache_statistics.num_cached_keys}</strong></td></tr>
        <tr><td>Max cached keys</td><td><strong>{$opcache_statistics.max_cached_keys}</strong></td></tr>
        <tr><td>Hits</td><td><strong>{$opcache_statistics.hits}</strong></td></tr>
        <tr><td>Misses</td><td><strong>{$opcache_statistics.misses}</strong></td></tr>
        <tr><td>OOM restarts</td><td><strong>{$opcache_statistics.oom_restarts}</strong></td></tr>
        <tr><td>Hash restarts</td><td><strong>{$opcache_statistics.hash_restarts}</strong></td></tr>
        <tr><td>Manual restarts</td><td><strong>{$opcache_statistics.manual_restarts}</strong></td></tr>
      </table>
    </div>
    {/if}

    {* JIT *}
    {if $jit}
    <div class="opcache-section">
      <h4>JIT</h4>
      <table class="table table-condensed">
        <tr><td>Enabled</td><td><strong>{if $jit.enabled}Yes{else}No{/if}</strong></td></tr>
        <tr><td>On</td><td><strong>{if $jit.on}Yes{else}No{/if}</strong></td></tr>
        <tr><td>Kind</td><td><strong>{$jit.kind}</strong></td></tr>
        <tr><td>Opt level</td><td><strong>{$jit.opt_level}</strong></td></tr>
        <tr><td>Buffer size</td><td><strong>{$jit.buffer_size|string_format:"%.2f"} MB</strong></td></tr>
        <tr><td>Buffer free</td><td><strong>{$jit.buffer_free|string_format:"%.2f"} MB</strong></td></tr>
      </table>
    </div>
    {/if}

  </div>
  {/if}
</div>
