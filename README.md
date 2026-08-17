# Sleepy Sales — Bagisto AliExpress Dropship

This repo wires up the [`bagisto/aliexpress-dropship`](https://github.com/bagisto/laravel-aliexpress-dropship)
extension and its scheduled **product-update cron**.

## What this package is

`bagisto/aliexpress-dropship` is an **extension for [Bagisto](https://bagisto.com)**,
the open-source Laravel e-commerce platform. Its code lives under the
`Webkul\Dropship\` namespace and is designed to be installed **into an existing
Bagisto store** — it is not a standalone application. It lets a store admin
import AliExpress products, automate order fulfilment, and keep prices/stock in
sync.

Two things are worth knowing before you install:

1. **No stable release exists.** The package only publishes dev branches
   (`dev-master`, `v1.5.1.x-dev`, …). A bare `composer require bagisto/aliexpress-dropship`
   fails against Composer's default `minimum-stability: stable`. The
   [`composer.json`](composer.json) here sets `minimum-stability: dev` +
   `prefer-stable: true` and pins the extension to `dev-master`, so the require
   resolves.
2. **It needs a Bagisto host.** The extension extends Bagisto core classes, so
   it only *runs* inside a real Bagisto store (Bagisto v1.3.2 per the extension's
   own requirements). Installed on its own, as in this repo, it materializes the
   dependency + lockfile but has no store to plug into.

## What's in this repo

| Path | Purpose |
| --- | --- |
| `composer.json` | Requires the extension with the correct dev-stability config. |
| `composer.lock` | Pinned, resolved dependency graph (run `composer install` to hydrate `vendor/`). |
| `schedule/dropship.crontab` | Ready-to-install crontab line for the 5-minute product sync. |
| `schedule/kernel-schedule.php` | Laravel-scheduler equivalent of the cron (version-controlled alternative). |
| `.gitignore` | Keeps `vendor/` out of git. |

## Install (this repo)

```bash
composer install
```

This reads `composer.lock` and installs `bagisto/aliexpress-dropship` (dev-master)
plus its dependencies into `vendor/`.

## Install into a real Bagisto store

Inside your Bagisto project root, follow the extension's official flow:

```bash
# 1. Pull in the extension (add the dev-stability config from this repo's
#    composer.json if your project uses minimum-stability: stable)
composer require bagisto/aliexpress-dropship:dev-master

# 2. Run the extension installer (registers config, migrations, assets)
php artisan aliexpress:install
```

## The product-update cron

The extension ships a `dropship:product:update` Artisan command that refreshes
imported AliExpress products' **price and quantity**. Bagisto's docs schedule it
every 5 minutes.

**Option A — raw crontab** (see [`schedule/dropship.crontab`](schedule/dropship.crontab)):

```cron
*/5 * * * * php /project_root_folder_path/artisan dropship:product:update
```

Replace `/project_root_folder_path` with the absolute path to your Bagisto
project (the directory containing `artisan`), and use the full path to `php` if
it isn't on cron's `PATH`.

**Option B — Laravel scheduler** (see [`schedule/kernel-schedule.php`](schedule/kernel-schedule.php)):
register `dropship:product:update` with `->everyFiveMinutes()` and use a single
`schedule:run` crontab entry. Keeps the schedule in version control.

### ⚠️ The cron is a no-op unless auto-update is enabled

`dropship:product:update` returns immediately unless **both** of these are turned
on in the store admin under **Configuration → Dropship settings**:

- `dropship.settings.auto_updation.price`
- `dropship.settings.auto_updation.quantity`

Enable them or the scheduled sync will run and do nothing.
