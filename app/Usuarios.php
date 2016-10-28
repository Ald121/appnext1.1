<?php

namespace App;

use Illuminate\Notifications\Notifiable;
use Illuminate\Foundation\Auth\User as Authenticatable;

class Usuarios extends Authenticatable
{
    use Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    public $connection='usuarioconex';
     protected $primaryKey='id';
     public $timestamps=false;
     public $incrementing=false;
    protected $fillable = [
        'id', 'nick', 'clave_clave',
    ];

    /**
     * The attributes that should be hidden for arrays.
     *
     * @var array
     */
    protected $hidden = [
        // 'clave_clave',
    ];

    public function getAuthPassword() {
    return $this->clave_clave;
    }

    public function changeConnection($conn)
    {
       return $this->connection = $conn;
    }
}
