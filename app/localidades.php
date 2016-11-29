<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class localidades extends Model
{
    protected $primaryKey='id';
	public $timestamps = false;
	public $incrementing=false;
	protected $connection='localidadesconex';
    protected $fillable=['id', 'nombre', 'codigo', 'id_padre', 'estado', 'fecha'];
    protected $hidden=['id', 'codigo', 'id_padre', 'estado', 'fecha'];
}
