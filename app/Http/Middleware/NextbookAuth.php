<?php

namespace App\Http\Middleware;

use Closure;

use App\Usuarios;
use Config;

class NextbookAuth
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @return mixed
     */
    public function handle($request, Closure $next)
    {
        if ($request->token=='') {
            return response(['error'=>'Sin-Token-de-Seguridad'], 401);
        }

        $usuarios=new Usuarios();
        $datos=$usuarios->select('nick')->where('id',$request->nick)->get();

        $name_bdd = $datos[0]['nick'];

        $name_bdd=strtolower($datos[0]['nick']);

        Config::set('database.connections.'.$name_bdd, array(
                'driver' => 'pgsql',
                'host' => 'localhost',
                'port' =>  '5432',
                'database' =>  $name_bdd,
                'username' =>  $name_bdd,
                'password' =>  $request->nick,
                'charset' => 'utf8',
                'prefix' => '',
                'schema' => 'public',
                'sslmode' => 'prefer',
        ));
        $usuarios=new Usuarios(); 
        $usuarios->changeConnection($name_bdd);
        // $user=$request->nick.'@facturanext.com';

        $datos=$usuarios->where('token',$request->input('token'))->get();
        if (count($datos)>0) {
            return $next($request);
        }else{
            return response(['error'=>'Usuario-no-Autorizado'], 401);
        }
        
    }
}
