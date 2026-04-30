<?php

namespace app\controller;

class InstallController
{
    public function index()
    {
        $file = public_path('install/index.php');
        if (!file_exists($file)) {
            return response('<h1>install/index.php not found</h1>', 404);
        }
        return response(file_get_contents($file), 200, [
            'Content-Type' => 'text/html; charset=UTF-8',
        ])->file($file);
    }
}