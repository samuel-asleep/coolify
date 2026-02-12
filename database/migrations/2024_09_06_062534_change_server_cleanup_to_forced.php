<?php

use App\Models\ServerSetting;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Use raw SQL to avoid "cached plan must not change result type" error
        // This is more reliable with PostgreSQL when changing column defaults
        DB::statement("ALTER TABLE server_settings ALTER COLUMN force_docker_cleanup SET DEFAULT true");
        
        // Update existing rows that have force_docker_cleanup = false
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
        // Revert the default back to false
        DB::statement("ALTER TABLE server_settings ALTER COLUMN force_docker_cleanup SET DEFAULT false");
    }
};
