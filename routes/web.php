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
    Route::get('crear_bdd','pruebasController@crear_bdd');
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
    Route::post('Get_Categorias','categoriasController@Get_Categorias');
    Route::post('Update_Categoria','categoriasController@Update_Categoria');
    Route::post('Delete_Categoria','categoriasController@Delete_Categoria');
    // Tipo Categorias
    Route::post('Add_Tipo_Categoria','Tipos_Categorias_Controller@Add_Tipo_Categoria');
    Route::post('Get_Tipo_Categorias','Tipos_Categorias_Controller@Get_Tipo_Categorias');
    Route::post('Delete_Tipo_Categorias','Tipos_Categorias_Controller@Delete_Tipo_Categorias');
    Route::post('Update_Tipo_Categorias','Tipos_Categorias_Controller@Update_Tipo_Categorias');
    // Marcas
    Route::post('Add_Marca','MarcasController@Add_Marca');
    Route::post('Get_Marcas','MarcasController@Get_Marcas');
    Route::post('Update_Marca','MarcasController@Update_Marca');
    Route::post('Delete_Marca','MarcasController@Delete_Marca');
    // Tipo Garantias
    Route::post('Add_Tipo_Garantia','Tipos_GarantiasController@Add_Tipo_Garantia');
    Route::post('Get_Tipo_Garantias','Tipos_GarantiasController@Get_Tipo_Garantias');
    Route::post('Update_Tipo_Garantia','Tipos_GarantiasController@Update_Tipo_Garantia');
    Route::post('Delete_Tipo_Garantia','Tipos_GarantiasController@Delete_Tipo_Garantia');
    // Garantias
    Route::post('Add_Garantia','GarantiasController@Add_Garantia');
    Route::post('Get_Garantias','GarantiasController@Get_Garantias');
    Route::post('Update_Garantia','GarantiasController@Update_Garantia');
    Route::post('Delete_Garantia','GarantiasController@Delete_Garantia');
    // Modelos
    Route::post('Add_Modelo','ModelosController@Add_Modelo');
    Route::post('Get_Modelos','ModelosController@Get_Modelos');
    Route::post('Update_Modelo','ModelosController@Update_Modelo');
    Route::post('Delete_Modelo','ModelosController@Delete_Modelo');
    // Tipo Consumos
    Route::post('Add_Tipo_Consumo','Tipos_Consumos_Controller@Add_Tipo_Consumo');
    Route::post('Get_Tipo_Consumos','Tipos_Consumos_Controller@Get_Tipo_Consumos');
    Route::post('Update_Tipo_Consumo','Tipos_Consumos_Controller@Update_Tipo_Consumo');
    Route::post('Delete_Tipo_Consumo','Tipos_Consumos_Controller@Delete_Tipo_Consumo');
    // Ubicaciones
    Route::post('Add_Ubicacion','UbicacionesController@Add_Ubicacion');
    Route::post('Get_Ubicaciones','UbicacionesController@Get_Ubicaciones');
    Route::post('Update_Ubicacion','UbicacionesController@Update_Ubicacion');
    Route::post('Delete_Ubicacion','UbicacionesController@Delete_Ubicacion');
    // Productos
    Route::post('Add_Producto','ProductosController@Add_Producto');
    Route::post('Get_Productos','ProductosController@Get_Productos');
    // Tipo Producto
    Route::post('Add_Tipo_Producto','Tipos_Productos_Controller@Add_Tipo_Producto');
    Route::post('Get_Tipo_Productos','Tipos_Productos_Controller@Get_Tipo_Productos');
    Route::post('Update_Tipo_Producto','Tipos_Productos_Controller@Update_Tipo_Producto');
    Route::post('Delete_Tipo_Producto','Tipos_Productos_Controller@Delete_Tipo_Producto');
    // Tipos Catalogos
    Route::post('Add_Tipo_Catalogo','Tipos_Catalogos_Controller@Add_Tipo_Catalogo');
    Route::post('Get_Tipo_Catalogos','Tipos_Catalogos_Controller@Get_Tipo_Catalogos');
    Route::post('Update_Tipo_Catalogo','Tipos_Catalogos_Controller@Update_Tipo_Catalogo');
    Route::post('Delete_Tipo_Catalogo','Tipos_Catalogos_Controller@Delete_Tipo_Catalogo');
     // Catalogos
    Route::post('Add_Catalogo','CatalogosController@Add_Catalogo');
    Route::post('Get_Catalogos','CatalogosController@Get_Catalogos');
    Route::post('Update_Catalogo','CatalogosController@Update_Catalogo');
    Route::post('Delete_Catalogo','CatalogosController@Delete_Catalogo');
    

    Route::group(['middleware' => ['auth.nextbook']], function ()
    {
        // ////////////////////////////////////////////////// IMAGENES DE PERFIL //////////////
        // --------------------------------------- AÑADIR IMAGEN DE PERFIL -----------
        Route::post('Add_Img_Perfil', 'PerfilController@Add_Img_Perfil');
        // --------------------------------------- SELECCIONAR IMAGEN DE PERFIL -----------
        Route::post('Set_Img_Perfil', 'PerfilController@Set_Img_Perfil');
        // --------------------------------------- CARGAR IMAGENES PERFIL -----------
        Route::post('Load_Imgs_Perfil', 'PerfilController@Load_Imgs_Perfil');
        // --------------------------------------- GET IMAGENES PERFIL -----------
        Route::post('Get_Img_Perfil', 'PerfilController@Get_Img_Perfil');
        // --------------------------------------- DELETE IMAGENES PERFIL -----------
        Route::post('Delete_Img_Perfil', 'PerfilController@Delete_Img_Perfil');
                                // ////////////////////////////////////////////////// IMAGENES DE LOGO //////////////
        // --------------------------------------- AÑADIR IMAGEN DE LOGO -----------
        Route::post('Add_Img_Logo', 'LogoController@Add_Img_Logo');
        // --------------------------------------- SELECCIONAR IMAGEN DE LOGO -----------
        Route::post('Set_Img_Logo', 'LogoController@Set_Img_Logo');
        // --------------------------------------- CARGAR IMAGENES LOGO -----------
        Route::post('Load_Imgs_Logo', 'LogoController@Load_Imgs_Logo');
        // --------------------------------------- GET IMAGENES LOGO -----------
        Route::post('Get_Img_Logo', 'LogoController@Get_Img_Logo');
        // --------------------------------------- DELETE IMAGENES LOGO -----------
        Route::post('Delete_Img_Logo', 'LogoController@Delete_Img_Logo');
        // ////////////////////////////////////////////////// IMAGENES DE PORTADA //////////////
        // --------------------------------------- AÑADIR IMAGEN DE PORTADA -----------
        Route::post('Add_Img_Portada', 'PortadaController@add_img_portada');
        // --------------------------------------- SELECCIONAR IMAGEN DE PORTADA -----------
        Route::post('Set_Img_Portada', 'PortadaController@Set_Img_Portada');
        // --------------------------------------- CARGAR IMAGENES PORTADA -----------
        Route::post('Load_Imgs_Portada', 'PortadaController@Load_Imgs_Portada');
        // --------------------------------------- GET IMAGENES PORTADA -----------
        Route::post('Get_Img_Portada', 'PortadaController@Get_Img_Portada');
        // --------------------------------------- DELETE IMAGENES PERFIL -----------
        Route::post('Delete_Img_Portada', 'PortadaController@Delete_Img_Portada');
        // GET DATOS EMPRESA
        Route::post('Get_Datos_Empresa', 'Administracion_Empresa_Controller@Get_Datos_Empresa');
        //GETESTABLECIMIENTOS
        Route::post('Get_Establecimientos', 'Administracion_Empresa_Controller@Get_Establecimientos');
        //UPDATE PASSWORD
        Route::post('Update_Password', 'Administracion_Empresa_Controller@Update_Password');
    });
});
