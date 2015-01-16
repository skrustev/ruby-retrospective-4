def sequence(first, second, index)
  if index <= 2
    index == 1 ? first : second
  else
    sequence(first, second, index - 1) + sequence(first, second, index - 2)
  end
end

def series(name_sequence, index)
  return sequence(1, 1, index) if name_sequence == 'fibonacci'
  return sequence(2, 1, index) if name_sequence == 'lucas'
  sequence(1, 1, index) + sequence(2, 1, index) if name_sequence == 'summed'
end