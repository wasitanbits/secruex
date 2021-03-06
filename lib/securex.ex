defmodule SecureX do
  alias SecureX.Context

  @moduledoc """
  SecureX (An Advancement To ACL) is Role Based Access Control(RBAC) and Access Control List (ACL) to handle "User Roles And Permissions".
  You can handle all list of permissions attached to a specific object for certain users or give limited or full Access to specific
  module.

  It has 4 basic modules, `SecureX.Roles`, `SecureX.Res`, `SecureX.Permissions` and `SecureX.UserRoles`.
  All Modules have CRUD to maintain your RBAC.
  `SecureX` Module has validation for user.

  ## Installation

  If installing from Hex, use the latest version from there:
  ```elixir
  # mix.ex

   def deps do
    [
      {:securex, "~> 1.0.5"}
    ]
  end
  ```
  Now You need to add configuration for `securex` in your `config/config.ex`.
  You need to add Your Repo and User Schema in config.
  If you are using `binary_id` type for your project default as `@primary_keys`. You can pass `type: :binary_id`.
  ```elixir
  # config/config.exs

  config :securex, repo: MyApp.Repo, #required
   schema: MyApp.Schema.User, #required
   type: :binary_id #optional
  ```
  SecureX comes with built-in support for apps. Just create migrations with `mix secure_x.gen.migration`.
  ```elixir
  iex> mix securex.gen.migration
  * creating priv/repo/migrations
  * creating priv/repo/migrations/20211112222439_create_table_roles.exs
  * creating priv/repo/migrations/20211112222440_create_table_resources.exs
  * creating priv/repo/migrations/20211112222441_create_table_permissions.exs
  * creating priv/repo/migrations/20211112222442_create_table_user_roles.exs
  ```
  The Migrations added to your project.
  ```elixir
  iex> "Do you want to run this migration?"
  iex> mix ecto.migrate
  ```
  You are Now Up and Running!!!

  ## Pagination with Scrivener

  SecureX Supports pagination with `Scrivener` & `ScrivenerEcto`,
  Please read the following documentations if you have :
    -> https://hexdocs.pm/scrivener_ecto/readme.html
    -> https://hexdocs.pm/scrivener/readme.html

  Please add to your project Repo,
  ```
    use Scrivener, page_size: 10
  ```

  ## Guide

  You can also use SecureX as a Middleware.

  Valid inputs for permissions are "POST", "GET", "PUT", "DELETE", "read", "write", "edit" and "delete".
  Permissions have downward flow. i.e if you have defined permissions for a higher operation,
  It automatically assigns them permissions for lower operations.
  like "edit" grants permissions for all operations. Their hierarchy is in this order.

  ```
    "read" < "write" < "edit" < "delete"
    "GET" < "POST" < "PUT" < "DELETE"
    1 < 2 < 3 < 4
  ```

  ## Middlewares
  In RestApi or GraphiQL all you have to do, add a `Plug`.

  ## Examples
  ```elixir
   #lib/plugs/securex_plug.ex

    defmodule MyApp.Plugs.SecureXPlug do
      @behaviour Plug

      import Plug.Conn

      def init(default), do: default

      def call(conn, _) do
        with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
            {:ok, claims} <- MyApp.Auth.Guardian.decode_and_verify(token),
            {:ok, user} <- MyApp.Auth.Guardian.resource_from_claims(claims),
            {:ok, %Plug.Conn{}} <- check_permissions(conn, user) do
      conn
    else
      {:error, error} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(403, Jason.encode!(%{errors: error}))
        |> Plug.Conn.halt()
      _ ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(403, Jason.encode!(%{errors: ["Permission Denied"]}))
        |> Plug.Conn.halt()
    end
  end

  defp check_permissions(%{method: method, path_info: path_info} = conn, %{id: user_id}) do
    res = List.last(path_info)
    case SecureX.has_access?(user_id, res, method) do
      false -> {:error, false}
      true -> {:ok, conn}
    end
  end
  defp check_permissions(_, _), do: {:error, ["Invalid Request"]}
  end
  ```
  You are all set.
  Please let us know about the issues and open issue on https://github.com/DevWasi/secruex/issues.
  Looking Forward to it :D.

  Happy Coding !!!!!
  """

  @doc """
  Check if user has access.

  ## Examples

      iex> has_access?(1, "users", "write")
      true

      iex> has_access?(1, "Gibberish", "bad_input")
      false
  """
  @spec has_access?(any(), String.t(), any()) :: boolean()
  def has_access?(user_id, res_id, permission)
      when not is_nil(user_id) and not is_nil(res_id) and not is_nil(permission) do
    with value when is_integer(value) <- translate_permission(permission),
         %{id: res_id} <- Context.get_resource(res_id),
         roles <- Context.get_user_roles_by_user_id(user_id),
         %{permission: per} <- Context.get_permission_by(res_id, roles),
         true <- value <= per do
      true
    else
      _ -> false
    end
  end

  defp translate_permission(permission) do
    cond do
      permission in ["GET", "get", "READ", "read", "1", 1] ->
        1

      permission in [
        "GET",
        "get",
        "READ",
        "read",
        "1",
        1,
        "POST",
        "post",
        "write",
        "WRITE",
        "2",
        2
      ] ->
        2

      permission in [
        "GET",
        "get",
        "READ",
        "read",
        "1",
        1,
        "POST",
        "post",
        "write",
        "WRITE",
        "2",
        2,
        "UPDATE",
        "update",
        "PUT",
        "put",
        "edit",
        "EDIT",
        "3",
        3
      ] ->
        3

      permission in [
        "GET",
        "get",
        "READ",
        "read",
        "1",
        1,
        "POST",
        "post",
        "write",
        "WRITE",
        "2",
        2,
        "UPDATE",
        "update",
        "PUT",
        "put",
        "edit",
        "EDIT",
        "3",
        3,
        "DELETE",
        "delete",
        "DROP",
        "drop",
        "REMOVE",
        "remove",
        "4",
        4
      ] ->
        4

      true ->
        nil
    end
  end
end
