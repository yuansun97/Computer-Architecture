#include "utils.h"

uint32_t extract_tag(uint32_t address, const CacheConfig& cache_config) {
  // TODO
  uint32_t num_tag_bits = cache_config.get_num_tag_bits();
  if (num_tag_bits == 0) return 0;
  return address >> (32 - num_tag_bits);
}

uint32_t extract_index(uint32_t address, const CacheConfig& cache_config) {
  // TODO
  uint32_t num_offset_bits = cache_config.get_num_block_offset_bits();
  uint32_t num_idx_bits = cache_config.get_num_index_bits();
  if (num_idx_bits >= 32) return 0;
  uint32_t mask = (1 << num_idx_bits) - 1;
  address = address >> num_offset_bits;
  return mask & address;
}

uint32_t extract_block_offset(uint32_t address, const CacheConfig& cache_config) {
  // TODO
  uint32_t num_offset_bits = cache_config.get_num_block_offset_bits();
  if (num_offset_bits >= 32) return 0;
  uint32_t mask = (1 << num_offset_bits) - 1;
  return mask & address;
}
