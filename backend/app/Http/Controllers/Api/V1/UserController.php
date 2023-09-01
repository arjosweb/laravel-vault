<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use PHPUnit\Exception;

class UserController extends Controller
{
    private User $user;
    private Request $request;

    public function __construct(User $user, Request $request)
    {
        $this->user = $user;
        $this->request = $request;
    }

    public function index(): JsonResponse
    {
        $users = $this->user
            //->with(['links'])
            ->orderBy('id', 'DESC')
            //->get();
            ->paginate(10);

        return response()->json($users);
    }

    public function store(): JsonResponse
    {
        try {
            $user = new $this->user;
            $user->fill($this->request->all());

            if ($this->request->has('password') && $this->request->get('password')) {
                $user->password = bcrypt($this->request->get('password'));
            }

            $user->fill([
                'address' => $this->request->get('address'),
                'avatar' => $this->request->get('avatar'),
                'email' => $this->request->get('email'),
                'name' => $this->request->get('name'),
                'phone' => $this->request->get('phone'),
                'status_key' => $this->request->get('status_key'),
                'preferences' => $this->request->get('preferences'),
            ]);
            if (!$user->save()) {
                return response()->json(['success' => false, 'error' => 'Error.'], 406);
            }
            return response()->json($user);
        } catch (Exception $exception) {
            return response()->json(['success' => false, 'error' => 'Server error.'], 500);
        }
    }

    public function show($key): JsonResponse
    {
        $user = $this->user
            // ->with(['keys'])
            ->where('uuid', '=', $key);

        return response()->json($user);
    }

    public function update($key): JsonResponse
    {
        $user = $this->user->where('uuid', '=', $key);

        if ($this->request->has('password') && $this->request->get('password')) {
            $user->password = bcrypt($this->request->get('password'));
        }

        $user->fill([
            'address' => $this->request->get('address'),
            'avatar' => $this->request->get('avatar'),
            'email' => $this->request->get('email'),
            'name' => $this->request->get('name'),
            'phone' => $this->request->get('phone'),
            'status_key' => $this->request->get('status_key'),
            'preferences' => $this->request->get('preferences'),
        ]);

        $user->save();

        return response()->json($user);
    }

    public function destroy($key): JsonResponse
    {
        $this->user->where('uuid', '=', $key)->delete();

        return response()->json(null, 204);
    }
}
