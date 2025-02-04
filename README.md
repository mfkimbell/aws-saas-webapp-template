# SaaS Template with Authentication

This is a template for a SaaS application with authentication.

The frontend is built with Next.js and Tailwind CSS.

The backend is built with FastAPI and SQLAlchemy.

This template allows for a user to sign up, sign in, and sign out. It comes with a prebuilt user store made in redux, which persists across refreshes. All of the session logic is handled in the backend.

This template focuses on a credit system where users can purchase credits to use the application, with the ability to make an API key to use the application without the frontend. Though this can be easily modified to use a subscription model, by forcing the `requires_credit` function to not decrement the user's credit balance, to act as a subscription.

## Getting Started

The following environment variables are required:

- `JWT_SECRET`: A secret key for signing and verifying JWT tokens
- `NEXTAUTH_SECRET`: A secret key for signing and verifying NextAuth tokens
- `DATABASE_URL`: A URL for the database

The `JWT_SECRET` on the frontend and backend must be the same.

#### Example Env for Deveopment
`./env`
```
JWT_SECRET=<MATCHING PASSWORD>
APP_MODE=dev
DATABASE_URL=
```
`./frontend/env`
```
API_URL=http://localhost:8000
JWT_SECRET=<MATCHING PASSWORD>
NEXTAUTH_SECRET=<MATCHING PASSWORD>
```

#### Deployment Configuration
For DockerHub deployment via GitHub Actions, configure the following GitHub Secrets:

`DOCKERHUB_USERNAME` - Your DockerHub username. (e.g., mfkimbell).

`DOCKERHUB_TOKEN` - Your DockerHub access token.

`DOCKERHUB_REPO` - The repository name (e.g., aws-saas-template).

## Running the Application

1. Run `make build up` to build and start the containers
2. Visit `http://localhost:3000` to view the frontend



## Authentication
<img width="1109" alt="auth" src="https://github.com/user-attachments/assets/5e5b7260-b203-411d-b7ad-95196e88d9df" />

This application proxies api calls from NextJS's local api to the FastAPI, but only if they're authenticated (unless we are calling login, which requires no prior authorization). We use the same JWT secret in both the frontend and backend .env files to encode and decode our JWT tokens. Next.js knows the hashing algorithm because the backend includes it in the JWT header. If an attacker modifies the token payload (e.g., changing "id": 1 to "id": 999), the signature will no longer match.

We use the `Repository Pattern` in order to grab user data on the backend and we use a NextJS Session and `Redux` in order to grab and persist user data on the frontend. 

Instead of directly writing db.query(User).filter(User.id == 1), we call:

```python
user = UserManager.get_user_from_access_token(token)
```
This way, we decouple the application from the database. 

## Credit System

Each user starts with 0 credits and can be assigned credits in order to use backend routes created by the saas provider. 

The `Decorator Pattern` is a structural pattern that allows you to dynamically modify functions or objects without changing their original code.
In Python, decorators are implemented using higher-order functions (functions that take other functions as arguments).
They "wrap" another function to add extra behavior before or after it runs.

A paid route would be defined with an `@requires_credit` decorator:
```Python
@router.get("/generate-text")
@requires_credit(decrement=True)  # This decorator is applied
async def generate_text(user=Depends(UserManager.get_user_from_header)):
    return {"generated_text": "AI-generated text!"}
```
Here's what the function looks like:
```Python
def requires_credit(decrement: bool = True) -> Callable[[F], F]:
    def decorator(func: F) -> F:
        @wraps(func)
        async def wrapper(*args: Any, **kwargs: Any) -> Any:
            ...
            if user.credits == 0:
                raise HTTPException(status_code=403, detail="User has no credits")
            result = await func(*args, **kwargs) # actually calls function
            if decrement:
                UserManager.decrement_user_credits(user.id)
                result["credits"] = user.credits - 1
            else:
                result["credits"] = user.credits
            return JSONResponse(content=result)
        return wrapper  # pyright: ignore[reportReturnType]
    return decorator
```

## Request proxying
There is a custom fetch function in the React Frontend in lib/utils that adds "/api" in front of all calls and then adds the "<API_URL>" in front of that. So "/login" will go to NextJS's api as "/api/login" and then to the backend as "<API_URL>/login". To be clear, this is NOT used in the authentication logic, it is for developers to call their backend without manually calling the frontend api with a token. 
```typescript
export const nextApi = axios.create({
  baseURL: "/api",
});
```
```typescript
export async function fetch<T>(url: string, options?: AxiosRequestConfig)
{ ... 
const response: AxiosResponse<T> = await nextApi.get(url, options);
}
```
```typescript
const api = axios.create({
  baseURL: process.env.API_URL,
});
```
```typescript
response = await api.request({
        method: method,
        url: forwardPath,
        headers: headers,
        data: forwardedBody,
      });
```

## Unit Testing

Unit tests are run automatically during the `test` job in the `Test Python` github action.

This template using `pytest` to validate various backend routes. It uses an override for the "get_db()" function to perform its tests on a test database, while still testing production code. 

FastAPI has a built in "TestClient" is a wrapper around requests that allows sending HTTP requests directly to FastAPI applications in memory, without actually running a server.

It tests the register, login, and api-key logic. 




