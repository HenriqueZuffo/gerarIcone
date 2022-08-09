defmodule IconeAtividade do
  @moduledoc """
  Documentation for `IconeAtividade`.
  """

  def main(input) do
    input
    |> hash_input
    |> criar_cor
    |> criar_tabela
    |> remover_impar
    |> constroi_pixel
    |> desenhar
    |> salvar(input)
  end

  def salvar(imagem, input) do
    File.write('#{input}.png', imagem)
  end

  def desenhar(%IconeAtividade.Imagem{color: cor, pixel_map: pixel_map}) do
    imagem = :egd.create(250, 250)
    preencha = :egd.color(cor)

    Enum.each(pixel_map, fn {start, stop} ->
      :egd.filledRectangle(imagem, start, stop, preencha)
    end)

    :egd.render(imagem)
  end

  def constroi_pixel(%IconeAtividade.Imagem{grid: grid} = imagem) do
    pixel_map =
      Enum.map(grid, fn {_valor, indice} ->
        h = rem(indice, 5) * 50
        v = div(indice, 5) * 50
        t_esquerda = {h, v}
        i_direita = {h + 50, v + 50}
        {t_esquerda, i_direita}
      end)

    %IconeAtividade.Imagem{imagem | pixel_map: pixel_map}
  end

  def hash_input(input) do
    hex =
      :crypto.hash(:md5, input)
      |> :binary.bin_to_list()

    %IconeAtividade.Imagem{hex: hex}
  end

  def espelhar(linha) do
    [pri, sec | _tail] = linha
    linha ++ [sec, pri]
  end

  def criar_tabela(%IconeAtividade.Imagem{hex: hex} = imagem) do
    grid =
      hex
      |> Enum.chunk(3)
      |> Enum.map(&espelhar/1)
      |> List.flatten()
      |> Enum.with_index()

    %IconeAtividade.Imagem{imagem | grid: grid}
  end

  def criar_cor(%IconeAtividade.Imagem{hex: [r, g, b | _tail]} = imagem) do
    %IconeAtividade.Imagem{imagem | color: {r, g, b}}
  end

  def remover_impar(%IconeAtividade.Imagem{grid: grid} = imagem) do
    new_grid =
      Enum.filter(grid, fn {valor, _indice} ->
        rem(valor, 2) == 0
      end)

    %IconeAtividade.Imagem{imagem | grid: new_grid}
  end
end
