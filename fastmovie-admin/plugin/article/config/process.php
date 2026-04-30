<?php

use plugin\article\process\JoinPushMessage;
use Workerman\Events\Swoole;

return [
    'JoinPushMessage' => [
        'eventLoop' => 'Workerman\Events\Select',
        'handler'  => JoinPushMessage::class
    ],
];
