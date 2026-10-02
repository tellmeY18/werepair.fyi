defmodule Werepair.ForbiddenError do
  defexception message: "You cannot perform this action.", plug_status: 403
end
