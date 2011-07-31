package compression;

/**
 * Created by IntelliJ IDEA.
 * User: robert
 * Date: 30.07.11
 * Time: 22:18
 * To change this template use File | Settings | File Templates.
 */
public class BrnLZW {

  class CountInt {
    public int value;

    CountInt(int value) {
      this.value = value;
    }
  }

  public static final int BITS = 12;                   /* Setting the number of bits to 12, 13*/
  public static final int HASHING_SHIFT = (BITS-8);    /* or 14 affects several constants.    */
  public static final int MAX_VALUE = (1 << BITS) - 1; /* Note that MS-DOS machines need to   */
  public static final int MAX_CODE = MAX_VALUE - 1;    /* compile their code in large model if*/

  public static final int TABLE_SIZE = 5021;

  public static final int LZW_DECODE_STACK_SIZE = 8000;
  public static final int LZW_DECODE_ERROR = -1;
  public static final int LZW_ENCODE_ERROR = -1;

  public long  UINT_FILTER;

  int[] code_value;                  /* This is the code value array        */
  long[] prefix_code;        /* This array holds the prefix codes   */
  byte[] append_character;  /* This array holds the appended chars */
  byte[] decode_stack;      /* This array holds the decoded string */

  long b_mask;
  int n_bits_prev;
  int input_bit_count;
  long input_bit_buffer;
  int output_bit_count;
  long output_bit_buffer;

  public BrnLZW()
  {
    //TODO: Handle malloc-error
    code_value= new int[TABLE_SIZE];
    prefix_code=new long[TABLE_SIZE];
    append_character=new byte[TABLE_SIZE];
    decode_stack=new byte[LZW_DECODE_STACK_SIZE];


    if (code_value==null || prefix_code==null || append_character==null || decode_stack==null)
      System.out.println("Fatal error allocating table space!\n");
    else
      reset_tables();

    UINT_FILTER = ((long)0x0000ffff << 16) + 0x00000ffff;
  }

  void reset_tables()
  {
    b_mask = 0;
    n_bits_prev = 0;
    input_bit_count = 0;
    input_bit_buffer = 0L;
    output_bit_count = 0;
    output_bit_buffer = 0L;
  }

/*
** This routine simply decodes a string from the string table, storing
** it in a buffer.  The buffer can then be output in reverse order by
** the expansion program.
*/

  CountInt decode_string(byte[] buffer, CountInt buffer_index, long code)
  {
    int i = 0;

    while (code > 255)
    {
      if ( code >= TABLE_SIZE )
        return null;                     //HINT; Just to handle corrupt packets
      buffer[buffer_index.value] = append_character[(int)(code & UINT_FILTER)];
      buffer_index.value++;
      code = prefix_code[(int)(code & UINT_FILTER)];
      if (i++ >= MAX_CODE) {
        System.out.println("Fatal error during code expansion.\n");
        return new CountInt(-1);
      }
    }

    buffer[buffer_index.value] = (byte)code;

    return buffer_index;
  }

  long input_code(byte[] input, CountInt pos, int inputlen)
  {
    long c;
    long return_value;

    while (input_bit_count <= 24)
    {
      if ( pos.value >= inputlen ) return MAX_VALUE;
      c = ((long)input[pos.value]) & 0xff ;
      pos.value++;
      input_bit_buffer |= (c & UINT_FILTER) << (24-input_bit_count);
      input_bit_buffer &= UINT_FILTER;
      input_bit_count += 8;
    }

    return_value = input_bit_buffer >> (32-BITS);
    input_bit_buffer <<= BITS;
    input_bit_buffer = input_bit_buffer & (long)UINT_FILTER;
    input_bit_count -= BITS;

    return(return_value & UINT_FILTER);
  }

/*
**  This is the expansion routine.  It takes an LZW format file, and expands
**  it to an output file.  The code here should be a fairly close match to
**  the algorithm in the accompanying article.
*/
  public byte[] decode(byte[] input, int inputlen, int dec_len)
  {
    byte[] output = new byte[dec_len];
    long next_code;
    long new_code;
    long old_code;
    int character;
    CountInt string_index;
    CountInt inputpos;
    int outputpos;

    reset_tables();

    string_index = new CountInt(0);
    inputpos = new CountInt(0);
    outputpos = new Integer(0);             /* position inside outputbuffer */

    new_code = 256;            /* Init value. not need but better it avoids valgrind errors */
    next_code = 256;           /* This is the next available code to define */

    old_code=(input_code(input, inputpos, inputlen)) & UINT_FILTER;  /* Read in the first code, initialize the */
    character = (int)(old_code & UINT_FILTER);                               /* character variable, and send the first */
    output[outputpos] = (byte)old_code;
    outputpos++;

    /*
    **  This is the main expansion loop.  It reads in characters from the LZW file
    **  until it sees the special code used to inidicate the end of the data.
    */
    while ( (new_code = (input_code(input, inputpos, inputlen) & UINT_FILTER)) < MAX_VALUE)
    {
      /*
      ** This code checks for the special STRING+CHARACTER+STRING+CHARACTER+STRING
      ** case which generates an undefined code.  It handles it by decoding
      ** the last code, and adding a single character to the end of the decode string.
      */
      if (new_code>=next_code)
      {
        decode_stack[0] = (byte)character;
        string_index = decode_string(decode_stack, new CountInt(1), old_code & UINT_FILTER);
        if ( string_index.value == -1 ) return null;
      }
      /*
      ** Otherwise we do a straight decode of the new code.
      */
      else {
        string_index = decode_string(decode_stack, new CountInt(0), new_code);
        if ( string_index.value == -1 ) return null;
      }

      /*
      ** Now we output the decoded string in reverse order.
      */
      character = decode_stack[string_index.value];

      while (string_index.value >= 0) {
        output[outputpos] = decode_stack[string_index.value];
        string_index.value--;
        outputpos++;
      }
      /*
      ** Finally, if possible, add a new code to the string table.
      */
      if (next_code <= MAX_CODE)
      {
        prefix_code[(int)next_code]=old_code;
        append_character[(int)next_code]= (byte)character;
        next_code++;
      }

      old_code=new_code;
    }

    return output;
  }

}
