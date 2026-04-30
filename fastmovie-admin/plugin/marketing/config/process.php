<?php
use plugin\marketing\process\Expire;
use Workerman\Events\Swoole;

return [
    'CouponExpire'  => [
        'eventLoop' => 'Workerman\Events\Select',
        'handler'  => Expire::class
    ],
];
