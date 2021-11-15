defmodule SecureXWeb.UserRoleController do
  @moduledoc false

  use SecureXWeb, :controller
  alias SecureX.Common
  alias SecureX.SecureXContext, as: Context

  @doc """
  Create an User Role,

  ## Examples

      iex> create(%{"user_id" => 1, "role_id" => "super_admin"})
      %UserRole{
        id: 1,
        user_id: 1,
        role_id: "super_admin"
      }
  """
  @spec create(map()) :: struct()
  def create(params) when params !== %{} do
    case params do
      %{user_id: _, role_id: _} -> create_user_role_sage(params)
      %{"user_id" => _, "role_id" => _} ->
        params = Common.keys_to_atoms(params)
        create_user_role_sage(params)
      _-> {:error, :bad_input}
    end
  end
  def create(_), do: {:error, :bad_input}

  defp create_user_role_sage(params) do
    with nil <- Context.get_user_role_by(params.user_id, params.role_id),
         {:ok, user_role} <- Context.create_user_role(params) do
      {:ok, user_role}
    else
      %{__struct__: _} -> {:error, :alrady_exist}
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Delete an User Role,

  ## Examples

      iex> delete(%{"id" => 1)
      %Permission{
        id: 1,
        user_id: 1,
        role_id: "admin"
      }
  """
  @spec delete(map()) :: struct()
  def delete(params) when params !== %{} do
    case params do
      %{id: user_role_id} -> delete_user_role_sage(user_role_id)
      %{"id" => user_role_id} -> delete_user_role_sage(user_role_id)
      _-> {:error, :bad_input}
    end
  end
  def delete(_), do: {:error, :bad_input}

  defp delete_user_role_sage(user_role_id) do
    with %{__struct__: _} = user_role <- Context.get_user_role(user_role_id),
         {:ok, user_role} <- Context.delete_user_role(user_role) do
      {:ok, user_role}
    else
      nil -> {:error, :doesnt_exist}
      {:error, error} -> {:error, error}
    end
  end
end