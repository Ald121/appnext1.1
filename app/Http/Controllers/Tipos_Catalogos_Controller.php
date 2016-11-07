<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
// Extras
use DB;
use Carbon\Carbon;
	// Funciones
use App\libs\Funciones;
class Tipos_Catalogos_Controller extends Controller
{
	public function __construct(){
    	// Funciones
    	$this->funciones=new Funciones();
    }
    public function Add_Tipo_Catalogo(Request $request)
    {
    DB::connection('nextbookPRE')->table('inventario.tipos_catalogos')->insert(['nombre' => $request->input('nombre') , 'fecha_inicio' => $request->input('fecha_inicio') ,'fecha_fin' => $request->input('fecha_fin'),'descripcion' => $request->input('descripcion'), 'estado' => 'A', 'fecha' => Carbon::now()->toDateString()]);
    return response()->json(['respuesta' => true], 200);
    }
}
