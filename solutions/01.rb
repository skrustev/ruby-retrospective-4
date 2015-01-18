def sequence(first, second, index)
  if index <= 2
    index == 1 ? first : second
  else
    sequence(first, second, index - 1) + sequence(first, second, index - 2)
  end
end

def series(type, index)
  case type
  when 'fibonacci' then sequence(1, 1, index)
  when 'lucas' then sequence(2, 1, index)
  when 'summed' then sequence(1, 1, index) + sequence(2, 1, index)
  end
end