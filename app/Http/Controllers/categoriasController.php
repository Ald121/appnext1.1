<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Categorias;
// Extras
use DB;
use Carbon\Carbon;
// Funciones
use App\libs\Funciones;

class categoriasController extends Controller

  {
  public function __construct()
    {
    // Modelos
    $this->Categorias = new Categorias();
    $this->schema = 'inventario';
    // Funciones
    $this->funciones=new Funciones();
    }

  public function Add_Categoria(Request $request)
    {
    DB::connection('nextbookPRE')->table('inventario.categorias')->insert(['nombre' => $request->nombre, 'descripcion' => $request->descripcion, 'tipo_categoria' => $request->tipo_categoria, 'estado' => 'A', 'fecha' => Carbon::now()->toDateString()]);
    return response()->json(['respuesta' => true], 200);
    }

    public function Get_Categorias(Request $request)
    {
    $currentPage = $request->pagina_actual;
    $limit = $request->limit;
    $data=DB::connection('nextbookPRE')->table('inventario.categorias')->where('estado','A')->get();
    $data=$this->funciones->paginarDatos($data,$currentPage,$limit);
    return response()->json(['respuesta' => $data], 200);
    }

    public function Update_Categoria(Request $request)
    {
    $data=DB::connection('nextbookPRE')->table('inventario.categorias')->where('id',$request->id)->update(['nombre' => $request->nombre , 'descripcion' => $request->descripcion,'tipo_categoria' => $request->tipo_categoria]);
    return response()->json(['respuesta' => true], 200);
    }

    public function Delete_Categoria(Request $request)
    {
    $data=DB::connection('nextbookPRE')->table('inventario.categorias')->where('id',$request->id)->update(['estado'=>'I']);
    return response()->json(['respuesta' => true], 200);
    }

  
  }

