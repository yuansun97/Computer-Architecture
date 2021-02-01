#include "cacheconfig.h"
#include "utils.h"

CacheConfig::CacheConfig(uint32_t size, uint32_t block_size, uint32_t associativity)
: _size(size), _block_size(block_size), _associativity(associativity) {
  /**
   * TODO
   * Compute and set `_num_block_offset_bits`, `_num_index_bits`, `_num_tag_bits`.
  */ 
  _num_block_offset_bits = log_2(_block_size);
  _num_index_bits = log_2(_size / _associativity / _block_size);
  _num_tag_bits = 32 - _num_block_offset_bits - _num_index_bits;
}
