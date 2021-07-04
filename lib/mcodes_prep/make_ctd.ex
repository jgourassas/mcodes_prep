defmodule McodesPrep.MakeCtd do
  require Ecto.Query
  require TableRex.Table
  require Logger
  import McodesPrep.Utils

  def search_ctd() do
    print_searching_in("Search For a Disease synonym in CTD DB")

    synomym_field = IO.gets("\t Synonym name as: Stenocardia,  Diplegic > ") |> String.trim()

    synomym_q =
      Ecto.Query.from(p in McodesPrep.Ctd,
        order_by: [asc: p.diseasename],
        where: fragment("(?) @@ plainto_tsquery(?)", p.synonyms, ^"#{synomym_field}%"),
        select: %{
          diseasename: p.diseasename,
          synonyms: p.synonyms,
          definition: p.definition,
          diseaseid: p.diseaseid
        },
        limit: 5
      )

    records = synomym_q |> McodesPrep.Repo.all()

    if Enum.any?(records) do
      IO.puts(" ")

      IO.puts(
        IO.ANSI.magenta_background() <>
          IO.ANSI.white() <>
          " \u00A9 \u0391\u03A9 ---------- \u2022  Results For Synonym: #{synomym_field} \u2022 ----------  " <>
          IO.ANSI.reset()
      )

      IO.puts(" ")

      Enum.each(records, fn rec ->
        diseasename = rec[:diseasename]
        synonyms_long = rec[:synonyms]
        synonyms = String.replace(synonyms_long, "|", "^")
        definition = rec[:definition]
        diseaseid = rec[:diseaseid]

        IO.puts(" ")
        print_element(diseasename, IO.ANSI.reverse() <> "Disease Name" <> IO.ANSI.reverse_off())
        print_element(synonyms, "Synonyms")
        print_element(definition, "Definition")
        print_element(diseaseid, "Disease ID")
        IO.puts(" ")
      end)

      ## Enum.each
    else
      colorize_text("alert", "Nothing Found")
    end

    ## if any records

    response = get_response("Search Again a Synonym? [Y,N] ") |> String.upcase()

    case response do
      "Y" ->
        search_ctd()

      "N" ->
        colorize_text("default", "Ok. help for options, q to Quit")

      _ ->
        colorize_text("default", "Ok. help for options, q to Quit")
        McodesPrep.Cli.loop()
    end
  end

  # search
  ##########################
end

# module
