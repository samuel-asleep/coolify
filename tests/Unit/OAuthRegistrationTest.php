<?php

use App\Models\InstanceSettings;
use App\Models\User;

beforeEach(function () {
    // Create instance settings for testing
    InstanceSettings::updateOrCreate(
        ['id' => 0],
        [
            'is_registration_enabled' => false,
            'is_oauth_registration_enabled' => false,
            'enforce_oauth_only' => false,
        ]
    );
});

it('allows oauth registration when oauth registration is enabled', function () {
    $settings = InstanceSettings::find(0);
    $settings->is_registration_enabled = false;
    $settings->is_oauth_registration_enabled = true;
    $settings->save();

    // Create a mock OAuth user
    $user = User::factory()->create([
        'name' => 'OAuth User',
        'email' => 'oauth@example.com',
        'oauth_provider' => 'github',
    ]);

    expect($user->isOAuthUser())->toBeTrue();
});

it('blocks oauth registration when both registrations are disabled', function () {
    $settings = InstanceSettings::find(0);
    $settings->is_registration_enabled = false;
    $settings->is_oauth_registration_enabled = false;
    $settings->save();

    expect($settings->is_registration_enabled)->toBeFalse();
    expect($settings->is_oauth_registration_enabled)->toBeFalse();
});

it('identifies oauth users correctly', function () {
    $oauthUser = User::factory()->create([
        'name' => 'OAuth User',
        'email' => 'oauth@example.com',
        'oauth_provider' => 'github',
    ]);

    $passwordUser = User::factory()->create([
        'name' => 'Password User',
        'email' => 'password@example.com',
        'password' => bcrypt('password'),
    ]);

    expect($oauthUser->isOAuthUser())->toBeTrue();
    expect($passwordUser->isOAuthUser())->toBeFalse();
});

it('enforces oauth only authentication when enabled', function () {
    $settings = InstanceSettings::find(0);
    $settings->enforce_oauth_only = true;
    $settings->save();

    $oauthUser = User::factory()->create([
        'name' => 'OAuth User',
        'email' => 'oauth@example.com',
        'oauth_provider' => 'github',
    ]);

    $passwordUser = User::factory()->create([
        'name' => 'Password User',
        'email' => 'password@example.com',
        'password' => bcrypt('password'),
    ]);

    expect($oauthUser->isOAuthOnlyEnforced())->toBeTrue();
    expect($passwordUser->isOAuthOnlyEnforced())->toBeFalse();
});

it('does not enforce oauth only when setting is disabled', function () {
    $settings = InstanceSettings::find(0);
    $settings->enforce_oauth_only = false;
    $settings->save();

    $oauthUser = User::factory()->create([
        'name' => 'OAuth User',
        'email' => 'oauth@example.com',
        'oauth_provider' => 'github',
    ]);

    expect($oauthUser->isOAuthOnlyEnforced())->toBeFalse();
});
