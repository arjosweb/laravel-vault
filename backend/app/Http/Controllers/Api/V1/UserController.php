<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\User;
use Exception;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use function PHPUnit\Framework\exactly;

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
            ->orderBy('id', 'DESC')
            //->get();
            ->paginate(10);

        return response()->json($users);
    }

    public function store(FormRequest $request): JsonResponse
    {
        try {
            $data = $request->all();

            if ($request->has('password') && $request->input('password')) {
                $data['password'] = bcrypt($request->input('password'));
            }

            $user = $this->user->create($data);

            return response()->json($user, 201); // 201 Created status code.
        } catch (Exception $exception) {
            return response()->json(['success' => false, 'error' => 'Server error: '. $exception->getMessage()], 500);
        }
    }

    public function show($key): JsonResponse
    {
        $user = $this->user->where('uuid', '=', $key)->first();

        return response()->json($user);
    }

    public function update($key, FormRequest $request): JsonResponse
    {
        $user = $this->user->where('uuid', '=', $key)->first();

        if (!$user) {
            return response()->json(['error' => 'Usuário não encontrado'], 404);
        }

        $modelAttributes = array_keys($user->getAttributes());
        $data = $request->only($modelAttributes);

        if ($request->has('password') && $request->input('password')) {
            $data['password'] = bcrypt($request->input('password'));
        }

        $user->update($data);

        return response()->json($user);
    }

    public function destroy($key): JsonResponse
    {
        $this->user->where('uuid', '=', $key)->delete();

        return response()->json(null, 204);
    }
}
