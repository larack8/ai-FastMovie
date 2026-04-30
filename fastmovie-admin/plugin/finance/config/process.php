<?php
use plugin\finance\process\Expire;
use Workerman\Events\Swoole;

return [
    'OrdersExpire'  => [
        'eventLoop' => 'Workerman\Events\Select',
        'handler'  => Expire::class
    ],
];
