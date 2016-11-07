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
    DB::connection('nextbookPRE')->table('inventario.categorias')->insert(['nombre' => $request->input('nombre') , 'descripcion' => $request->input('descripcion') , 'tipo_categoria' => $request->input('tipo_categoria') , 'estado' => 'A', 'fecha' => Carbon::now()->toDateString()]);
    return response()->json(['respuesta' => true], 200);
    }

    public function Get_Categorias(Request $request)
    {
    $data=DB::connection('nextbookPRE')->table('inventario.categorias')->select('nombre','descripcion')->get();
    return response()->json(['respuesta' => $data], 200);
    }

  
  }

