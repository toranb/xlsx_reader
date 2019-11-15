defmodule XlsxReader.Styles do
  @known_styles %{
    # General
    "0" => :string,
    # 0
    "1" => :integer,
    # 0.00
    "2" => :float,
    # #,##0
    "3" => :float,
    # #,##0.00
    "4" => :float,
    # $#,##0_);($#,##0)
    "5" => :unsupported,
    # $#,##0_);[Red]($#,##0)
    "6" => :unsupported,
    # $#,##0.00_);($#,##0.00)
    "7" => :unsupported,
    # $#,##0.00_);[Red]($#,##0.00)
    "8" => :unsupported,
    # 0%
    "9" => :percentage,
    # 0.00%
    "10" => :percentage,
    # 0.00E+00
    "11" => :bignum,
    # # ?/?
    "12" => :unsupported,
    # # ??/??
    "13" => :unsupported,
    # mm-dd-yy
    "14" => :date,
    # d-mmm-yy
    "15" => :date,
    # d-mmm
    "16" => :date,
    # mmm-yy
    "17" => :date,
    # h:mm AM/PM
    "18" => :time,
    # h:mm:ss AM/PM
    "19" => :time,
    # h:mm
    "20" => :time,
    # h:mm:ss
    "21" => :time,
    # m/d/yy h:mm
    "22" => :date_time,
    # #,##0 ;(#,##0)
    "37" => :unsupported,
    # #,##0 ;[Red](#,##0)
    "38" => :unsupported,
    # #,##0.00;(#,##0.00)
    "39" => :unsupported,
    # #,##0.00;[Red](#,##0.00)
    "40" => :unsupported,
    # mm:ss
    "45" => :time,
    # [h]:mm:ss
    "46" => :time,
    # mmss.0
    "47" => :time,
    # ##0.0E+0
    "48" => :float,
    # @
    "49" => :unsupported
  }

  @supported_custom_formats [
    {"0.0%", :percentage},
    {"dd/mm/yyyy", :date},
    {"dd/mm/yyyy hh:mm", :date_time},
    {"hh:mm", :time}
  ]

  def get_style_type(num_fmt_id, custom_formats \\ %{}) do
    Map.get_lazy(
      @known_styles,
      num_fmt_id,
      fn -> get_style_type_from_custom_format(custom_formats, num_fmt_id) end
    )
  end

  defp get_style_type_from_custom_format(custom_formats, num_fmt_id) do
    custom_formats
    |> Map.get(num_fmt_id)
    |> custom_format_to_style_type(@supported_custom_formats)
  end

  defp custom_format_to_style_type(nil, _), do: nil
  defp custom_format_to_style_type(custom_format, []), do: custom_format

  defp custom_format_to_style_type(custom_format, [{custom_format, style_type} | _others]),
    do: style_type

  defp custom_format_to_style_type(custom_format, [{%Regex{} = regex, style_type} | others]) do
    if Regex.match?(regex, custom_format),
      do: style_type,
      else: custom_format_to_style_type(custom_format, others)
  end

  defp custom_format_to_style_type(custom_format, [_ | others]),
    do: custom_format_to_style_type(custom_format, others)
end
