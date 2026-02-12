<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        if (! Schema::hasColumn('server_settings', 'force_docker_cleanup')) {
            return;
        }

        Schema::table('server_settings', function (Blueprint $table) {
            $table->boolean('force_docker_cleanup')->default(true)->change();
        });

        DB::table('server_settings')
            ->where('force_docker_cleanup', false)
            ->update([
                'force_docker_cleanup' => true,
                'docker_cleanup_frequency' => '*/10 * * * *',
            ]);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        if (! Schema::hasColumn('server_settings', 'force_docker_cleanup')) {
            return;
        }

        Schema::table('server_settings', function (Blueprint $table) {
            $table->boolean('force_docker_cleanup')->default(false)->change();
        });
    }
};
