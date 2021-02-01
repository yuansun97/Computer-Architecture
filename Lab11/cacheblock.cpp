#include "cacheblock.h"

uint32_t Cache::Block::get_address() const {
  // TODO
  uint32_t tag_shifted = _tag << (32 - _cache_config.get_num_tag_bits());
  uint32_t idx_shifted = _index << _cache_config.get_num_block_offset_bits();
  return tag_shifted | idx_shifted;
}
