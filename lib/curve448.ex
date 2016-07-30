defmodule Curve448 do
  import Bitwise

  @moduledoc """
  Curve448 Diffie-Hellman functions

  """
  @typedoc """
  public or secret key
  """
  @type key :: <<_:: 224>>

  @p 726838724295606890549323807888004534353641360687318060281490199180612328166730772686396383698676545930088884461843637361053498018365439
  @a 156326

  defp clamp(c) do
    c |> band(~~~3)
      |> bor(128 <<< 8 * 55)
  end

  defp square(x), do: x * x # :math.pow yields floats.. and we only need this one

  defp expmod(_b,0,_m), do: 1
  defp expmod(b,e,m) do
       t = b |> expmod(div(e,2), m) |> square |> rem(m)
       if (e &&& 1) == 1, do: (t * b) |> rem(m), else: t
  end

  defp inv(x), do: x|> expmod(@p - 2, @p)

  defp add({xn,zn}, {xm,zm}, {xd,zd}) do
       x = (xm * xn - zm * zn) |> square |> (&(&1 * 4 * zd)).()
       z = (xm * zn - zm * xn) |> square |> (&(&1 * 4 * xd)).()
       {rem(x,@p), rem(z,@p)}
  end
  defp double({xn,zn}) do
       x = (square(xn) - square(zn)) |> square
       z = 4 * xn * zn * (square(xn) + @a * xn * zn + square(zn))
      {rem(x,@p),  rem(z,@p)}
  end

  def curve448(n, base) do
    one = {base,1}
    two = double(one)
    {{x,z}, _} = nth_mult(n, {one,two})
    (x * inv(z)) |> rem(@p)
  end

  defp nth_mult(1, basepair), do: basepair
  defp nth_mult(n, {one,two}) do
     {pm, pm1} = n |> div(2) |> nth_mult({one,two})
     if (n &&& 1) == 1, do: { add(pm, pm1, one), double(pm1) }, else: { double(pm), add(pm, pm1, one) }
  end

  @doc """
  Generate a secret/public key pair

  Returned tuple contains `{random_secret_key, derived_public_key}`
  """
  @spec generate_key_pair :: {key,key}
  def generate_key_pair do
    secret = :crypto.strong_rand_bytes(56) # This algorithm is supposed to be resilient against poor RNG, but use the best we can
    {secret, derive_public_key(secret)}
  end

  @doc """
  Derive a shared secret for a secret and public key

  Given our secret key and our partner's public key, returns a
  shared secret which can be derived by the partner in a complementary way.
  """
  @spec derive_shared_secret(key,key) :: key | :error
  def derive_shared_secret(our_secret, their_public) when byte_size(our_secret) == 56 and byte_size(their_public) == 56 do
    our_secret |> :binary.decode_unsigned(:little)
               |> clamp
               |> curve448(:binary.decode_unsigned(their_public, :little))
               |> :binary.encode_unsigned(:little)
  end
  def derive_shared_secret(_ours,_theirs), do: :error

  @doc """
  Derive the public key from a secret key
  """
  @spec derive_public_key(key) :: key | :error
  def derive_public_key(our_secret) when byte_size(our_secret) == 56 do
    our_secret |> :binary.decode_unsigned(:little)
               |> clamp
               |> curve448(5)
               |> :binary.encode_unsigned(:little)
  end
  def derive_public_key(_ours), do: :error

end
