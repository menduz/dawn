ByteAddressBuffer firstMatrix : register(t0, space0);
ByteAddressBuffer secondMatrix : register(t1, space0);
RWByteAddressBuffer resultMatrix : register(u2, space0);
cbuffer cbuffer_uniforms : register(b3, space0) {
  uint4 uniforms[1];
};

float mm_readA(uint row, uint col) {
  const int scalar_offset = (0u) / 4;
  bool tint_tmp = (row < uniforms[scalar_offset / 4][scalar_offset % 4]);
  if (tint_tmp) {
    const int scalar_offset_1 = (4u) / 4;
    tint_tmp = (col < uniforms[scalar_offset_1 / 4][scalar_offset_1 % 4]);
  }
  if ((tint_tmp)) {
    const int scalar_offset_2 = (4u) / 4;
    const float result = asfloat(firstMatrix.Load((4u * ((row * uniforms[scalar_offset_2 / 4][scalar_offset_2 % 4]) + col))));
    return result;
  }
  return 0.0f;
}

float mm_readB(uint row, uint col) {
  const int scalar_offset_3 = (4u) / 4;
  bool tint_tmp_1 = (row < uniforms[scalar_offset_3 / 4][scalar_offset_3 % 4]);
  if (tint_tmp_1) {
    const int scalar_offset_4 = (8u) / 4;
    tint_tmp_1 = (col < uniforms[scalar_offset_4 / 4][scalar_offset_4 % 4]);
  }
  if ((tint_tmp_1)) {
    const int scalar_offset_5 = (8u) / 4;
    const float result = asfloat(secondMatrix.Load((4u * ((row * uniforms[scalar_offset_5 / 4][scalar_offset_5 % 4]) + col))));
    return result;
  }
  return 0.0f;
}

void mm_write(uint row, uint col, float value) {
  const int scalar_offset_6 = (0u) / 4;
  bool tint_tmp_2 = (row < uniforms[scalar_offset_6 / 4][scalar_offset_6 % 4]);
  if (tint_tmp_2) {
    const int scalar_offset_7 = (8u) / 4;
    tint_tmp_2 = (col < uniforms[scalar_offset_7 / 4][scalar_offset_7 % 4]);
  }
  if ((tint_tmp_2)) {
    const int scalar_offset_8 = (8u) / 4;
    const uint index = (col + (row * uniforms[scalar_offset_8 / 4][scalar_offset_8 % 4]));
    resultMatrix.Store((4u * index), asuint(value));
  }
}

static const uint RowPerThread = 4u;
static const uint ColPerThread = 4u;
static const uint TileAOuter = 64u;
static const uint TileBOuter = 64u;
static const uint TileInner = 64u;

struct tint_array_wrapper_1 {
  float arr[64];
};
struct tint_array_wrapper {
  tint_array_wrapper_1 arr[64];
};

groupshared tint_array_wrapper mm_Asub;
groupshared tint_array_wrapper mm_Bsub;

struct tint_symbol_1 {
  uint3 local_id : SV_GroupThreadID;
  uint local_invocation_index : SV_GroupIndex;
  uint3 global_id : SV_DispatchThreadID;
};
struct tint_array_wrapper_2 {
  float arr[16];
};
struct tint_array_wrapper_3 {
  float arr[4];
};

[numthreads(16, 16, 1)]
void main(tint_symbol_1 tint_symbol) {
  const uint3 local_id = tint_symbol.local_id;
  const uint3 global_id = tint_symbol.global_id;
  const uint local_invocation_index = tint_symbol.local_invocation_index;
  if ((local_invocation_index == 0u)) {
    const tint_array_wrapper tint_symbol_5 = {(tint_array_wrapper_1[64])0};
    mm_Asub = tint_symbol_5;
    const tint_array_wrapper tint_symbol_6 = {(tint_array_wrapper_1[64])0};
    mm_Bsub = tint_symbol_6;
  }
  GroupMemoryBarrierWithGroupSync();
  const uint tileRow = (local_id.y * RowPerThread);
  const uint tileCol = (local_id.x * ColPerThread);
  const uint globalRow = (global_id.y * RowPerThread);
  const uint globalCol = (global_id.x * ColPerThread);
  const int scalar_offset_9 = (4u) / 4;
  const uint numTiles = (((uniforms[scalar_offset_9 / 4][scalar_offset_9 % 4] - 1u) / TileInner) + 1u);
  tint_array_wrapper_2 acc = (tint_array_wrapper_2)0;
  float ACached = 0.0f;
  tint_array_wrapper_3 BCached = (tint_array_wrapper_3)0;
  {
    uint index = 0u;
    while (true) {
      if (!((index < (RowPerThread * ColPerThread)))) {
        break;
      }
      acc.arr[index] = 0.0f;
      {
        index = (index + 1u);
      }
    }
  }
  const uint ColPerThreadA = (TileInner / 16u);
  const uint tileColA = (local_id.x * ColPerThreadA);
  const uint RowPerThreadB = (TileInner / 16u);
  const uint tileRowB = (local_id.y * RowPerThreadB);
  {
    uint t = 0u;
    while (true) {
      if (!((t < numTiles))) {
        break;
      }
      {
        uint innerRow = 0u;
        while (true) {
          if (!((innerRow < RowPerThread))) {
            break;
          }
          {
            uint innerCol = 0u;
            while (true) {
              if (!((innerCol < ColPerThreadA))) {
                break;
              }
              const uint inputRow = (tileRow + innerRow);
              const uint inputCol = (tileColA + innerCol);
              mm_Asub.arr[inputRow].arr[inputCol] = mm_readA((globalRow + innerRow), ((t * TileInner) + inputCol));
              {
                innerCol = (innerCol + 1u);
              }
            }
          }
          {
            innerRow = (innerRow + 1u);
          }
        }
      }
      {
        uint innerRow = 0u;
        while (true) {
          if (!((innerRow < RowPerThreadB))) {
            break;
          }
          {
            uint innerCol = 0u;
            while (true) {
              if (!((innerCol < ColPerThread))) {
                break;
              }
              const uint inputRow = (tileRowB + innerRow);
              const uint inputCol = (tileCol + innerCol);
              mm_Bsub.arr[innerCol].arr[inputCol] = mm_readB(((t * TileInner) + inputRow), (globalCol + innerCol));
              {
                innerCol = (innerCol + 1u);
              }
            }
          }
          {
            innerRow = (innerRow + 1u);
          }
        }
      }
      GroupMemoryBarrierWithGroupSync();
      {
        uint k = 0u;
        while (true) {
          if (!((k < TileInner))) {
            break;
          }
          {
            uint inner = 0u;
            while (true) {
              if (!((inner < ColPerThread))) {
                break;
              }
              BCached.arr[inner] = mm_Bsub.arr[k].arr[(tileCol + inner)];
              {
                inner = (inner + 1u);
              }
            }
          }
          {
            uint innerRow = 0u;
            while (true) {
              if (!((innerRow < RowPerThread))) {
                break;
              }
              ACached = mm_Asub.arr[(tileRow + innerRow)].arr[k];
              {
                uint innerCol = 0u;
                while (true) {
                  if (!((innerCol < ColPerThread))) {
                    break;
                  }
                  const uint index = ((innerRow * ColPerThread) + innerCol);
                  acc.arr[index] = (acc.arr[index] + (ACached * BCached.arr[innerCol]));
                  {
                    innerCol = (innerCol + 1u);
                  }
                }
              }
              {
                innerRow = (innerRow + 1u);
              }
            }
          }
          {
            k = (k + 1u);
          }
        }
      }
      GroupMemoryBarrierWithGroupSync();
      {
        t = (t + 1u);
      }
    }
  }
  {
    uint innerRow = 0u;
    while (true) {
      if (!((innerRow < RowPerThread))) {
        break;
      }
      {
        uint innerCol = 0u;
        while (true) {
          if (!((innerCol < ColPerThread))) {
            break;
          }
          const uint index = ((innerRow * ColPerThread) + innerCol);
          mm_write((globalRow + innerRow), (globalCol + innerCol), acc.arr[index]);
          {
            innerCol = (innerCol + 1u);
          }
        }
      }
      {
        innerRow = (innerRow + 1u);
      }
    }
  }
  return;
}
