#include <bits/stdc++.h>
#include <common.h>
#include <cstdlib>

template <typename T> int check_diff(T *A, T *B, int n) {
    int res = 0;
    double eps = 1e-8;
    for (int i = 0; i < n; i++) {
        if (abs(A[i] - B[i]) > eps)
            ++res;
    }
    return res;
}

__global__ void sum_kernel(float *A, float *B, float *C, int nx, int ny) {
    int ix = threadIdx.x + blockDim.x * blockIdx.x;
    int iy = threadIdx.y + blockDim.y * blockIdx.y;

    int idx = ix + iy * nx;
    if (ix < nx && iy < ny) {
        C[idx] = A[idx] + B[idx];
    }
}

void sumMatrixHost(float *A, float *B, float *C, int nx, int ny) {
    for (int iy = 0; iy < ny; iy++) {
        for (int ix = 0; ix < nx; ix++) {
            int idx = iy * nx + ix;
            C[idx] = A[idx] + B[idx];
        }
    }
}

void sumMatrixDevice(float *A, float *B, float *C, int nx, int ny, int dx,
                     int dy) {
    dim3 block_dim(dx, dy);
    dim3 grid_dim((nx + dx - 1) / dx, (ny + dy - 1) / dy);
    sum_kernel<<<grid_dim, block_dim>>>(A, B, C, nx, ny);
}

int main() {
    srand(time(nullptr));
    int nx = 1 << 14, ny = 1 << 12;
    int nxy = nx * ny;
    int nbytes = nxy * sizeof(nxy);
    float *ha, *hb, *href, *gref;
    ha = new float[nxy], hb = new float[nxy], href = new float[nxy],
    gref = new float[nxy];
    {
        PROFILE_BLOCK("FILL MEMS HOST");
        fillData(ha, nxy);
        fillData(hb, nxy);
    }

    href = new float[nxy], gref = new float[nxy];
    float *da, *db, *dc;
    cudaMalloc((void **)&da, nbytes);
    cudaMalloc((void **)&db, nbytes);
    cudaMalloc((void **)&dc, nbytes);
    {
        PROFILE_BLOCK("DATA HOST 2 DEVICE");
        cudaMemcpy(da, ha, nbytes, cudaMemcpyHostToDevice);
        cudaMemcpy(db, hb, nbytes, cudaMemcpyHostToDevice);
    }

    {
        PROFILE_BLOCK("HOST");
        sumMatrixHost(ha, hb, href, nx, ny);
    }

    {
        PROFILE_BLOCK("DEVICE");
        sumMatrixDevice(da, db, dc, nx, ny, 32, 32);
    }

    cudaMemcpy(gref, dc, nbytes, cudaMemcpyDeviceToHost);

    int cnt = check_diff(href, gref, nxy);
    std::cout << cnt << '\n';
    return 0;
}