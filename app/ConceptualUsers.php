<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class ConceptualUsers extends Model
{
    protected $connection='nextbookconex';
    protected $filleable=['id','clave_clave','nick','id_estado','fecha_creacion']
}
