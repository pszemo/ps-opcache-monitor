{**
 * OPcache Monitor - Full configuration page
 *}
<div class="opcache-monitor-admin">

  {* Header *}
  <div class="panel">
    <div class="panel-heading">
      <i class="icon-bolt"></i> OPcache Monitor
      {if $opcache_enabled}
        <span class="badge badge-success">ENABLED</span>
      {else}
        <span class="badge badge-danger">DISABLED</span>
      {/if}
      {if $cache_full}
        <span class="badge badge-warning">CACHE FULL</span>
      {/if}
    </div>
    <div class="panel-body">
      <a href="{$reset_url|escape:'html':'UTF-8'}" class="btn btn-warning">
        <i class="icon-refresh"></i> Reset OPcache
      </a>
      <p class="help-block">Resets all cached scripts. Use after deploying new code.</p>
    </div>
  </div>

  {* Version info *}
  {if $version}
    <div class="panel">
      <div class="panel-heading"><i class="icon-info-circle"></i> Version</div>
      <div class="panel-body">
        <table class="table table-striped">
          {foreach from=$version key=key item=val}
            <tr>
              <td><code>{$key|escape:'html':'UTF-8'}</code></td>
              <td><strong>{$val|escape:'html':'UTF-8'}</strong></td>
            </tr>
          {/foreach}
        </table>
      </div>
    </div>
  {/if}

  {* Hit rate + Memory *}
  <div class="row">
    <div class="col-md-6">
      <div class="panel">
        <div class="panel-heading"><i class="icon-signal"></i> Hit Rate</div>
        <div class="panel-body text-center">
          <div class="opcache-big-number {if $hit_rate >= 90}text-success{elseif $hit_rate >= 70}text-warning{else}text-danger{/if}">
            {$hit_rate}%
          </div>
          <div class="progress" style="height: 20px;">
            <div class="progress-bar {if $hit_rate >= 90}progress-bar-success{elseif $hit_rate >= 70}progress-bar-warning{else}progress-bar-danger{/if}"
                 style="width: {$hit_rate}%">{$hit_rate}%</div>
          </div>
        </div>
      </div>
    </div>
    <div class="col-md-6">
      <div class="panel">
        <div class="panel-heading"><i class="icon-hdd"></i> Memory Usage</div>
        <div class="panel-body">
          <table class="table table-condensed">
            <tr><td>Total</td><td><strong>{$memory_total_mb} MB</strong></td></tr>
            <tr class="success"><td>Used</td><td><strong>{$memory_used_mb} MB</strong></td></tr>
            <tr class="info"><td>Free</td><td><strong>{$memory_free_mb} MB</strong></td></tr>
            <tr class="warning"><td>Wasted</td><td><strong>{$memory_wasted_mb} MB</strong></td></tr>
          </table>
          <div class="progress">
            <div class="progress-bar progress-bar-success" style="width: {$memory_used_pct}%" title="Used">{$memory_used_pct}%</div>
          </div>
        </div>
      </div>
    </div>
  </div>

  {* Statistics *}
  {if $opcache_statistics}
    <div class="panel">
      <div class="panel-heading"><i class="icon-bar-chart"></i> Statistics</div>
      <div class="panel-body">
        <table class="table table-striped table-bordered">
          <thead><tr><th>Key</th><th>Value</th></tr></thead>
          <tbody>
          <tr><td>Cached scripts</td><td><strong>{$opcache_statistics.num_cached_scripts}</strong></td></tr>
          <tr><td>Cached keys</td><td><strong>{$opcache_statistics.num_cached_keys}</strong></td></tr>
          <tr><td>Max cached keys</td><td><strong>{$opcache_statistics.max_cached_keys}</strong></td></tr>
          <tr><td>Hits</td><td><strong>{$opcache_statistics.hits}</strong></td></tr>
          <tr><td>Misses</td><td><strong>{$opcache_statistics.misses}</strong></td></tr>
          <tr><td>Blacklist misses</td><td><strong>{$opcache_statistics.blacklist_misses}</strong></td></tr>
          <tr><td>Blacklist miss ratio</td><td><strong>{$opcache_statistics.blacklist_miss_ratio|string_format:"%.4f"}</strong></td></tr>
          <tr><td>OOM restarts</td><td><strong>{$opcache_statistics.oom_restarts}</strong></td></tr>
          <tr><td>Hash restarts</td><td><strong>{$opcache_statistics.hash_restarts}</strong></td></tr>
          <tr><td>Manual restarts</td><td><strong>{$opcache_statistics.manual_restarts}</strong></td></tr>
          <tr><td>Start time</td><td><strong>{$opcache_statistics.start_time|date_format:"%Y-%m-%d %H:%M:%S"}</strong></td></tr>
          <tr><td>Last restart time</td><td>
              <strong>
                {if $opcache_statistics.last_restart_time > 0}
                  {$opcache_statistics.last_restart_time|date_format:"%Y-%m-%d %H:%M:%S"}
                {else}
                  Never
                {/if}
              </strong>
            </td></tr>
          </tbody>
        </table>
      </div>
    </div>
  {/if}

  {* Interned strings *}
  {if $interned_strings}
    <div class="panel">
      <div class="panel-heading"><i class="icon-font"></i> Interned Strings</div>
      <div class="panel-body">
        <table class="table table-striped table-bordered">
          <tr><td>Buffer size</td><td><strong>{($interned_strings.buffer_size / 1024 / 1024)|string_format:"%.2f"} MB</strong></td></tr>
          <tr><td>Used memory</td><td><strong>{($interned_strings.used_memory / 1024 / 1024)|string_format:"%.2f"} MB</strong></td></tr>
          <tr><td>Free memory</td><td><strong>{($interned_strings.free_memory / 1024 / 1024)|string_format:"%.2f"} MB</strong></td></tr>
          <tr><td>Number of strings</td><td><strong>{$interned_strings.number_of_strings}</strong></td></tr>
        </table>
      </div>
    </div>
  {/if}

  {* JIT *}
  {if $jit}
    <div class="panel">
      <div class="panel-heading"><i class="icon-flash"></i> JIT (Just-In-Time Compiler)</div>
      <div class="panel-body">
        <table class="table table-striped table-bordered">
          <tr><td>Enabled</td><td><strong>{if $jit.enabled}<span class="label label-success">Yes</span>{else}<span class="label label-default">No</span>{/if}</strong></td></tr>
          <tr><td>Active (on)</td><td><strong>{if $jit.on}<span class="label label-success">Yes</span>{else}<span class="label label-default">No</span>{/if}</strong></td></tr>
          <tr><td>Kind</td><td><strong>{$jit.kind}</strong></td></tr>
          <tr><td>Opt level</td><td><strong>{$jit.opt_level}</strong></td></tr>
          <tr><td>Opt flags</td><td><strong>{$jit.opt_flags}</strong></td></tr>
          <tr><td>Buffer size</td><td><strong>{($jit.buffer_size / 1024 / 1024)|string_format:"%.2f"} MB</strong></td></tr>
          <tr><td>Buffer free</td><td><strong>{($jit.buffer_free / 1024 / 1024)|string_format:"%.2f"} MB</strong></td></tr>
        </table>
      </div>
    </div>
  {/if}

  {* Directives *}
  {if $directives}
    <div class="panel">
      <div class="panel-heading"><i class="icon-cog"></i> Configuration Directives (php.ini)</div>
      <div class="panel-body">
        <p class="text-muted small">
          <span class="label label-success">&#10003;</span> = matches recommendation &nbsp;
          <span class="label label-warning">&#9888;</span> = differs from recommendation
        </p>
        <table class="table table-striped table-bordered table-condensed">
          <thead>
          <tr>
            <th>Directive</th>
            <th>Current value</th>
            <th>Dev</th>
            <th>Prod</th>
            <th>Notes</th>
          </tr>
          </thead>
          <tbody>
          {foreach from=$directives key=key item=val}
            <tr>
              <td><code>{$key|escape:'html':'UTF-8'}</code></td>
              <td>
                {if $val === true}
                  <span class="label label-success">true</span>
                {elseif $val === false}
                  <span class="label label-default">false</span>
                {elseif $val === ''}
                  <em class="text-muted">empty</em>
                {else}
                  <strong>{$val|escape:'html':'UTF-8'}</strong>
                {/if}
              </td>
              {if isset($recommendations[$key])}
                <td><code>{$recommendations[$key][0]}</code></td>
                <td><code>{$recommendations[$key][1]}</code></td>
                <td><small class="text-muted">{$recommendations[$key][2]}</small></td>
              {else}
                <td colspan="3"><small class="text-muted">—</small></td>
              {/if}
            </tr>
          {/foreach}
          </tbody>
        </table>
      </div>
    </div>
  {/if}

  {* Cached scripts *}
  {if $scripts}
    <div class="panel">
      <div class="panel-heading">
        <i class="icon-file-code-o"></i>
        Cached Scripts (top 100 by hits, total: {$scripts_total})
      </div>
      <div class="panel-body">
        <div class="table-responsive">
          <table class="table table-striped table-bordered table-condensed opcache-scripts-table">
            <thead>
            <tr>
              <th>Path</th>
              <th>Hits</th>
              <th>Memory (KB)</th>
              <th>Last used</th>
              <th>Revalidate</th>
            </tr>
            </thead>
            <tbody>
            {foreach from=$scripts item=script}
              <tr>
                <td class="opcache-script-path"><small>{$script.path|escape:'html':'UTF-8'}</small></td>
                <td><strong>{$script.hits}</strong></td>
                <td>{$script.memory}</td>
                <td><small>{$script.last_used}</small></td>
                <td><small>{$script.revalidate}</small></td>
              </tr>
            {/foreach}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  {/if}

</div>
