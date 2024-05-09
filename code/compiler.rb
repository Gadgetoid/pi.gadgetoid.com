#!/usr/bin/ruby

STRUCTURE_MAP = {

    :BYTE => '00000000',
    :HALF_BYTE => '0000'

}

REGISTER_MAP = {

    'ACC' => '0000',
    'GP1' => '0001',
    'GP2' => '0010',
    'GP3' => '0011',
    'GP4' => '0100',

    'PC'  => '1111',
    'AF'  => '1110',
    'SF'  => '1101'

}

INSTRUCTION_MAP = {

    'NOOP' => {
        :instruction => '0001',
        :structure => {} },
    'LM'   => {
        :instruction => '0010',
        :structure => [:REGISTER_ADDR, :MEMORY_ADDR] },
    'ML'   => {
        :instruction => '0011',
        :structure => [:REGISTER_ADDR, :MEMORY_ADDR] },
    'LN'   => {
        :instruction => '0100',
        :usage => 'LN Target 0x1 or LN Target 0b00000001 or LN Target 1',
        :structure => [:REGISTER_ADDR, :INPUT_BYTE]},
    'MV'   => {
        :instruction => '0101',
        :usage => 'MV Target Source',
        :structure => [:REGISTER_ADDR, :REGISTER_ADDR, :HALF_BYTE]},
    'ADD'  => {
        :instruction => '0110',
        :usage => 'ADD Target SourceA SourceB',
        :structure => [:REGISTER_ADDR, :REGISTER_ADDR, :REGISTER_ADDR]},
    'SUB'  => {
        :instruction => '0111',
        :usage => 'SUB Target SourceA SourceB',
        :structure => [:REGISTER_ADDR, :REGISTER_ADDR, :REGISTER_ADDR]},
    'CMP'  => {
        :instruction => '1000',
        :structure => [:REGISTER_ADDR, :REGISTER_ADDR, :HALF_BYTE]},
    'JUMP' => {
        :instruction => '1001',
        :structure => [:OPTION, :LABEL],
        :ops => {
            'UN'  => '0000',
            'EQL' => '0001',
            'NE'  => '0010',
            'GT'  => '0011'
        }
    }
}

labels = Hash.new


if ARGV.length < 1
  raise 'You must specify input file'
end

if ARGV.length < 2
  ARGV[1] = ARGV[0].sub('.ass','.bin')
end

input_filename = ARGV[0]

output_filename = ARGV[1]

puts "Reading file " + input_filename

   input_file = File.read(input_filename)

program_lines = input_file.split("\n")

line_counter = 0
program_hash = Hash.new
program_lines.each do |line|

  if line.chomp != '' then

    line_addr = line_counter.to_s(2).rjust(8,'0')

    # Remove tabs, comments and trailing spaces
    line = line.gsub("\t",'').split('--')[0].strip

    #Split on space into command array
    line = line.split(' ')

    #p line

    # Expand shorthand accumilator add/sub with ACC and ACC as the target and first source
    if (line[0] == 'ADD' or line[0] == 'SUB') and line.length == 2
      line[3] = line[1]
      line[1] = line[2] = 'ACC'
    end

    # Rewrite loop shorthand to an unconditional jump
    if line[0] == 'LOOP'
      line[0] = 'JUMP'
      line[2] = line[1]
      line[1] = 'UN'
    end

    #Strip labels and add to lookup table
    if line[0] =~ /[a-z]\:/

      labels[ line[0].sub(':','') ] = line_addr

    else

      program_hash[ line_addr ] = line

      line_counter+=1

    end

  end

end

program_hash.each do |k,v|

  puts 'Compiling operation ' + v[0]
  instruction_detail = INSTRUCTION_MAP[ v[0] ]

  if instruction_detail.nil?
    raise 'Compile Failed: Unknown Instruction'
  end

  #puts instruction_detail

  v[0] = instruction_detail[:instruction]

  instruction_detail[:structure].each_with_index do |part,index|

    input_string = v[index+1]

    if part == :LABEL then
      input_string =  labels[input_string]
    end

    if part == :OPTION
      input_string = instruction_detail[:ops][input_string]
    end

    if part == :REGISTER_ADDR
      input_string = REGISTER_MAP[ input_string ]
    end

    if part == :INPUT_BYTE || part == :MEMORY_ADDR
      if input_string =~ /0b[0-9]*/
        input_string = input_string.sub('0b','')
      elsif input_string =~ /0x[0-9]*/
        input_string = input_string.to_i(16).to_s(2).rjust(8,'0')
      else
        input_string = input_string.to_i.to_s(2).rjust(8,'0')
      end
    end

    if part == :HALF_BYTE
      input_string = '0000'
    end

    if part == :BYTE
      input_string = '00000000'
    end

    v[index+1] = input_string

  end

  #puts 'Compiled to ' + v.join('')
  program_hash[k]  = v.join

end

output = Array.new

program_hash.each do |key,value|
  output << value.to_i(2).to_s(16) #.rjust(16,'0')
  puts value
end
puts output.join(' ')

puts 'Writing to ' + output_filename

File.open(output_filename, 'w') {|f| f.write("v2.0 raw\n" + output.join(' '))}