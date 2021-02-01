#include "simplecache.h"

/**
 * For find, you will have to look up the set of blocks that 
 * corresponds to the given index, and find the correct block within that: 
 * meaning that the block should be valid, and its tag should match the given tag. 
 * If such a block exists, return the correct byte within the block. 
 * If not, return 0xdeadbeef, the universal slaughterhouse ‘bad address’ code.
 * */

int SimpleCache::find(int index, int tag, int block_offset) {
  // read handout for implementation details
  if (index < 0) return 0xdeadbeef;

  std::map<int, std::vector< SimpleCacheBlock >>::iterator it = _cache.find(index);
  // it: the iterator pointing to the target pair {index, vec<block>}.
  if (it != _cache.end()) {
    for (auto way : it->second) {
      if (way.tag() == tag && way.valid()) {
        return way.get_byte(block_offset);
      }
    }
  }
  return 0xdeadbeef;
}

/**
 * For insert, you will again look up the set of blocks corresponding 
 * to the given index. Next, look through the set for an invalid block. 
 * If there is one, replace it with the block being inserted and return. 
 * If not,replace the 0th block of the set (overwriting whatever was in it). 
 * Use the provided replace function in simplecache.h.
 * */
void SimpleCache::insert(int index, int tag, char data[]) {
  // read handout for implementation details
  // keep in mind what happens when you assign in C++ (hint: Rule of Three)
  if (index < 0 || _associativity <= 0) return;

  std::map<int, std::vector< SimpleCacheBlock >>::iterator it = _cache.find(index);
  // it: the iterator pointing to the target pair {index, vec<block>}.
  if (it == _cache.end()) return;
  // it->second: vec<block> -- the set containing the target block.
  for (auto & way : it->second) {
    if (!way.valid()) {
      way.replace(tag, data);
      return;
    }
  }
  // Replace the 0th block
  it->second[0].replace(tag, data);
}
