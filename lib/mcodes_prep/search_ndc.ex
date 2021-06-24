defmodule McodesPrep.SearchNdc do
  require Ecto.Query
  require Logger
  import  McodesPrep.Utils
  alias   McodesPrep.Utils, as: Utils
  alias  McodesPrep.Ndc_product

  def search_ndc() do
 print_searching_in("Search NDC")

    term = get_response("Type a Propriatary Name as: Aspirin" )
    query =  Ecto.Query.from p in McodesPrep.Ndc_product,
      order_by: [asc: p.proprietaryname],
      where: fragment("(?) @@ plainto_tsquery(?)", p.proprietaryname,   ^("#{term}%")  )
       or fragment("(?) ilike(?)", p.substancename,   ^("#{term}%") )   ,
      select: [ p.proprietaryname,p.dosageforname, p.marketingcategoryname ],
      limit: 25



    records =  query |> McodesPrep.Repo.all
    header = ["Prop Name", "Form", "Market Nname"]
    title = "Results For #{term}. Limited to 12 Records and ordered by Prop Name"

    if Enum.any?(records) do
      print_results_title(term)
      Utils.present_tablerex(records, header, title)
    else
      colorize_text("alert", "Nothing Found")
    end #Enum.any

        response_options()

  end#search_ndc

  ###########################
  def response_options() do
    response = get_response( "Search in NDC Products Again? [Y,N] / Show Single Record [R]") |> String.upcase
    case response do
      "Y" ->
        search_ndc()

      "R" ->
        #show_ndc_record()
        colorize_text("default", "Ok. Showing Record")
        McodesPrep.Cli.loop()

      "N" ->
        colorize_text("default", "Ok. help for options")
        McodesPrep.Cli.loop()
      _ ->
        colorize_text("default", "Ok. help for options, q to Quit")
        McodesPrep.Cli.loop()
    end#case

  end# response_options
  #########################




end#module
