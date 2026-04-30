<?php

use plugin\model\process\audio\AudioTransfer;
use plugin\model\process\chat\Submit;
use plugin\model\process\draw\ImageTransfer;
use plugin\model\process\video\VideoTransfer;
use Workerman\Events\Swoole;

return [
    'ChatSubmit' => [
        'eventLoop' => 'Workerman\Events\Select',
        'handler'  => Submit::class,
        'count' => 5
    ],
    'ImageTransfer' => [
        'eventLoop' => 'Workerman\Events\Select',
        'handler'  => ImageTransfer::class,
        'count' => 5
    ],
    'VideoTransfer' => [
        'eventLoop' => 'Workerman\Events\Select',
        'handler'  => VideoTransfer::class,
        'count' => 5
    ],
    'AudioTransfer' => [
        'eventLoop' => 'Workerman\Events\Select',
        'handler'  => AudioTransfer::class,
        'count' => 5
    ],
];
