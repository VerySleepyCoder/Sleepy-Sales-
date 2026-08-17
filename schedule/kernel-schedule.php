<?php

/*
|--------------------------------------------------------------------------
| Laravel scheduler alternative to the raw crontab line
|--------------------------------------------------------------------------
|
| Instead of adding `dropship:product:update` directly to your server crontab,
| you can register it with Laravel's scheduler. This keeps the schedule in
| version control and needs only ONE crontab entry for the whole app:
|
|     * * * * * php /project_root_folder_path/artisan schedule:run >> /dev/null 2>&1
|
| Then add the command below to your Bagisto app's console schedule.
|
| - Laravel 10 and earlier: inside the schedule() method of
|   app/Console/Kernel.php
| - Laravel 11+ : in routes/console.php using the Schedule facade
|   (use Illuminate\Support\Facades\Schedule;)
|
| The dropship extension already registers the command, so no extra wiring is
| required beyond scheduling it.
*/

// app/Console/Kernel.php  (Laravel <= 10)
protected function schedule(Schedule $schedule): void
{
    $schedule->command('dropship:product:update')
        ->everyFiveMinutes()
        ->withoutOverlapping();
}

// routes/console.php  (Laravel >= 11)
use Illuminate\Support\Facades\Schedule;

Schedule::command('dropship:product:update')
    ->everyFiveMinutes()
    ->withoutOverlapping();
