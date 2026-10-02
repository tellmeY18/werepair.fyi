defmodule WerepairWeb.FormErrors do
  def messages(changeset),
    do:
      Enum.map(changeset.errors, fn {field, error} ->
        "#{field}: #{WerepairWeb.CoreComponents.translate_error(error)}"
      end)
end
