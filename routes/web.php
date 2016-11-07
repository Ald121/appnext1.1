<?php

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| This file is where you may define all of the routes that are handled
| by your application. Just tell Laravel the URIs it should respond
| to using a Closure or controller method. Build something great!
|
*/

Route::get('/', function () {
    return view('welcome');
});

Route::group(['middleware' => 'cors'], function(){
    Route::post('Save_Datos_Ruc','RegistroController@Save_Datos_Ruc');
	Route::post('Buscar_Empresas','busquedaEmpresas@Buscar_Empresas');
	// --------------------- Datos de Perfil Empresa----------------------------------
    Route::post('Get_Perfil_Empresas', 'busquedaEmpresas@Get_Perfil_Empresas');
    // --------------------- Buscar Empresa----------------------------------
    Route::post('Buscar_Informacion_Ruc', 'RegistroController@Buscar_Informacion_Ruc');
    // --------------------- GET provincias ----------------------------------
    Route::post('Get_Provincias', 'RegistroController@Get_Provincias'); 
    // --------------------- ACTIVAR CUENTA  ----------------------------------
    Route::post('Activar_Cuenta', 'RegistroController@Activar_Cuenta');
    // Ingreso
    Route::post('Acceso','loginController@Acceso');
    // Categorias
    Route::post('Add_Categoria','categoriasController@Add_Categoria');
    Route::post('Add_Tipo_Categoria','Tipos_Categorias_Controller@Add_Tipo_Categoria');
    Route::post('Get_Tipo_Categorias','Tipos_Categorias_Controller@Get_Tipo_Categorias');
    Route::post('Get_Categorias','categoriasController@Get_Categorias');
    // Marcas
    Route::post('Add_Marca','MarcasController@Add_Marca');
    // Garantias
    Route::post('Add_Tipo_Garantia','Tipo_GarantiasController@Add_Tipo_Garantia');
    Route::post('Add_Garantia','GarantiasController@Add_Garantia');
    // Modelos
    Route::post('Add_Modelo','ModelosController@Add_Modelo');
    // Tipos de Consumo
    Route::post('Add_Tipo_Consumo','Tipos_Consumos_Controller@Add_Tipo_Consumo');
    // Ubicaciones
    Route::post('Add_Ubicacion','UbicacionesController@Add_Ubicacion');
    // Productos
    Route::post('Add_Producto','ProductosController@Add_Producto');
    Route::post('Add_Tipo_Productos','Tipos_Productos_Controller@Add_Tipo_Productos');
    // Catalogos
    Route::post('Add_Tipo_Catalogo','Tipos_Catalogos_Controller@Add_Tipo_Catalogo');
    Route::post('Add_Catalogo','CatalogosController@Add_Catalogo');
    Route::post('Get_Catalogos','CatalogosController@Get_Catalogos');
    

    Route::group(['middleware' => ['auth.nextbook']], function ()
    { 
    });
});
