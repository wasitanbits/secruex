defmodule SecureX.Res do
  alias SecureXWeb.{ ResourceController }

  @moduledoc """

  """

  @doc """
  Add a Resource. You can send either `Atom Map` or `String Map` to add Resource.

  ## Examples

      iex> add(%{"res" => "Person Farm"})
      %Resource{
        id: "person_farm",
        name: "Persons Farm"
      }
  """
  @spec add(map()) :: struct()
  def add(params) do
    case ResourceController.create(params) do
      {:error, error} -> {:error, error}
      {:ok, role} -> {:ok, role}
    end
  end

  @doc """
  Update a Resource. You can update any resource along with its permissions.
  You can send either `Atom Map` or `String Map` to update Role. It will automatically
  update `resource_id` in `Permissions` table.

  ## Examples

      iex> update(%{"id" => "person_farm", "name" => "Person Organization"})
      %Resource{
        id: "person_organization",
        name: "Person Organization",
        permissions: :successfully_updated_permissions
      }

  """
  @spec update(map()) :: struct()
  def update(params) do
    case ResourceController.update(params) do
      {:error, error} -> {:error, error}
      {:ok, role} -> {:ok, role}
    end
  end

  @doc """
  Delete a Resource. All `Permissions` will be removed against this resource.

  ## Examples

      iex> delete(%{"id" => "person_organization")
      %Resource{
        id: "person_organization",
        name: "Person Organization",
        permissions: :successfully_removed_permissions
      }
  """
  @spec delete(map()) :: struct()
  def delete(params) do
    case ResourceController.delete(params) do
      {:error, error} -> {:error, error}
      {:ok, role} -> {:ok, role}
    end
  end
end