<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class ingresos_usuarios extends Model
{
    protected $primaryKey='id';
	public $timestamps = false;
	public $incrementing=false;
	protected $connection='auditoriaconex';
    protected $fillable=['id', 'usuario', 'ip_acceso', 'informacion_servidor', 'fecha'];
    // protected $hidden=['id', 'usuario', 'ip_acceso', 'informacion_servidor', 'fecha'];
}
