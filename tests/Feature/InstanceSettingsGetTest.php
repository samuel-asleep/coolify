<?php

use App\Models\InstanceSettings;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

it('creates default instance settings when missing', function () {
    expect(InstanceSettings::query()->whereKey(0)->exists())->toBeFalse();

    $settings = InstanceSettings::get();

    expect($settings->id)->toBe(0)
        ->and($settings->is_registration_enabled)->toBeTrue()
        ->and($settings->smtp_enabled)->toBeTrue()
        ->and($settings->smtp_host)->toBe('coolify-mail')
        ->and($settings->smtp_port)->toBe(1025)
        ->and($settings->smtp_from_address)->toBe('hi@localhost.com')
        ->and($settings->smtp_from_name)->toBe('Coolify');
});

it('returns existing instance settings without overriding values', function () {
    InstanceSettings::create([
        'id' => 0,
        'smtp_enabled' => false,
        'smtp_host' => 'smtp.example.com',
    ]);

    $settings = InstanceSettings::get();

    expect($settings->id)->toBe(0)
        ->and($settings->smtp_enabled)->toBeFalse()
        ->and($settings->smtp_host)->toBe('smtp.example.com');
});
