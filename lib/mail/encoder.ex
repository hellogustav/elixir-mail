defmodule Mail.Encoder do
  @moduledoc """
  Primary encoding/decoding bottleneck for the library.

  Will delegate to the proper encoding/decoding functions based upon name
  """

  @spec encoder_for(encoding :: String.t | atom) :: atom
  def encoder_for(encoding) when is_atom(encoding) do
    encoding
    |> Atom.to_string()
    |> encoder_for()
  end

  def encoder_for(encoding) when is_binary(encoding) do
    case encoding |> String.trim |> String.downcase do
      "7bit" -> Mail.Encoders.SevenBit
      "8bit" -> Mail.Encoders.EightBit
      "base64" -> Mail.Encoders.Base64
      "quoted-printable" -> Mail.Encoders.QuotedPrintable
      _ -> Mail.Encoders.Binary
    end
  end

  def encoder_for_string(encoding) when is_binary(encoding) do
    case encoding |> String.trim do
      "B" -> Mail.Encoders.Base64
      "Q" -> Mail.Encoders.QuotedPrintable
      _ -> Mail.Encoders.Binary
    end
  end

  @spec encode(data :: binary, encoding :: String.t) :: binary
  def encode(data, encoding), do: encoder_for(encoding).encode(data)

  @spec decode(data :: binary, encoding :: String.t) :: binary
  def decode(data, encoding), do: encoder_for(encoding).decode(data)

  @spec decode_string(data :: binary) :: binary
  def decode_string(data) do
    ~r/=\?(?<_format>.*)\?(?<encoding>[A-Z])\?(?<string>.*)\?=/
    |> Regex.named_captures(data)
    |> case do
      nil -> data
      %{"encoding" => encoding, "string" => string} -> encoder_for_string(encoding).decode(string)
    end
  end
end
