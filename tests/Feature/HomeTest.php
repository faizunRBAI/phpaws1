<?php

namespace Tests\Feature;

use Tests\TestCase;

class HomeTest extends TestCase
{
    public function test_home_page_renders(): void
    {
        $this->get('/')->assertStatus(200);
    }

    public function test_health_endpoint_reports_ok(): void
    {
        $this->get('/health')
            ->assertStatus(200)
            ->assertJson(['status' => 'ok']);
    }
}
