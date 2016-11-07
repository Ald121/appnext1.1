<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
// Funciones
use App\libs\Funciones;
// Extras
use DB;
use Carbon\Carbon;

class Tipos_Categorias_Controller extends Controller
{
	public function __construct(){
    	// Funciones
    	$this->funciones=new Funciones();
    }

    public function Add_Tipo_Categoria(Request $request)
    {
    DB::connection('nextbookPRE')->table('inventario.tipos_categorias')->insert(['nombre' => $request->input('nombre') , 'descripcion' => $request->input('descripcion') , 'estado' => 'A', 'fecha' => Carbon::now()->toDateString() ]);
    return response()->json(['respuesta' => true], 200);
    }

    public function Get_Tipo_Categorias(Request $request)
    {

    $currentPage = $request->input('pagina_actual');
    $limit = $request->input('limit');

    $data=DB::connection('nextbookPRE')->table('inventario.tipos_categorias')->select('nombre','descripcion')->get();
    $data=$this->funciones->paginarDatos($data,$currentPage,$limit);
    return response()->json(['respuesta' => $data], 200);
    }
}
