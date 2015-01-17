def sequence(first, second, index)
  if index <= 2
    index == 1 ? first : second
  else
    sequence(first, second, index - 1) + sequence(first, second, index - 2)
  end
end

def series(type, index)
  return sequence(1, 1, index) if type == 'fibonacci'
  return sequence(2, 1, index) if type == 'lucas'
  sequence(1, 1, index) + sequence(2, 1, index) if type == 'summed'
end