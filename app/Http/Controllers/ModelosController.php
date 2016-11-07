<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
// Extras
use DB;
use Carbon\Carbon;
	// Funciones
use App\libs\Funciones;
class ModelosController extends Controller
{

	public function __construct(){
    	// Funciones
    	$this->funciones=new Funciones();
    }
    public function Add_Modelo(Request $request)
    {
    DB::connection('nextbookPRE')->table('inventario.modelos')->insert(['nombre' => $request->input('nombre') , 'descripcion' => $request->input('descripcion') , 'estado' => 'A', 'fecha' => Carbon::now()->toDateString()]);
    return response()->json(['respuesta' => true], 200);
    }
}
