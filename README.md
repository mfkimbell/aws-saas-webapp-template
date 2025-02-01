# aws-saas-webapp-template

# SaaS Template with Authentication

This is a template for a SaaS application with authentication.

The frontend is built with Next.js and Tailwind CSS.

The backend is built with FastAPI and SQLAlchemy.

This template allows for a user to sign up, sign in, and sign out. It comes with a prebuilt user store made in redux. All of the session logic is handled in the backend.

This template focuses on a credit system where users can purchase credits to use the application, with the ability to make an API key to use the application without the frontend. Though this can be easily modified to use a subscription model, by forcing the `requires_credit` function to not decrement the user's credit balance, to act as a subscription.

## Environment Variables

The following environment variables are required:

- `JWT_SECRET`: A secret key for signing and verifying JWT tokens
- `NEXTAUTH_SECRET`: A secret key for signing and verifying NextAuth tokens
- `DATABASE_URL`: A URL for the database

The `JWT_SECRET` on the frontend and backend must be the same.

## Getting Started

1. Clone the repository
2. Run `pdm install` to install the backend dependencies
3. Run `cd frontend` and then `npm install` to install the frontend dependencies

## Running the Application

1. Run `make build up` to build and start the containers
2. Visit `http://localhost:3000` to view the frontend

How to run:
root .env
```
JWT_SECRET=<MATCHING PASSWORD>
APP_MODE=dev
DATABASE_URL=
```
frontend .env
```
API_URL=http://localhost:8000
JWT_SECRET=<MATCHING PASSWORD>
NEXTAUTH_SECRET=<MATCHING PASSWORD>

```

## Authentication
<img width="1109" alt="auth" src="https://github.com/user-attachments/assets/5e5b7260-b203-411d-b7ad-95196e88d9df" />



## Credit System

Each user starts with 0 credits and can be assigned credits in order to use backend routes created by the saas provider. 

The Decorator Pattern is a structural pattern that allows you to dynamically modify functions or objects without changing their original code.
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
    """
    Decorator factory that requires a user to have credits to use the function.

    If decrement is True, the user's credits will be decremented.
    Attaches the user's credits to the response.
    """

    def decorator(func: F) -> F:
        @wraps(func)
        async def wrapper(*args: Any, **kwargs: Any) -> Any:
            user = kwargs.get("user")

            if user is None:
                raise HTTPException(status_code=401, detail="Invalid token")

            user = cast(User, user)

            LOG.info(f"User: {user.username}, has {user.credits} credits")

            if user.credits == 0:
                raise HTTPException(status_code=403, detail="User has no credits")

            result = await func(*args, **kwargs)

            if decrement:
                UserManager.decrement_user_credits(user.id)
                result["credits"] = user.credits - 1
            else:
                result["credits"] = user.credits

            return JSONResponse(content=result)

        return wrapper  # pyright: ignore[reportReturnType]

    return decorator
```
If the original function's return looked liked this:
```
{
  "generated_text": "AI-generated text!"
}
```
The new response would look like this if the user had 5 credits:
```
{
  "generated_text": "AI-generated text!",
  "credits": 4  # Updated credit amount after deduction
}
```
Or like this if the user had 0 credits:
```
{
  "detail": "User has no credits"
}
```
