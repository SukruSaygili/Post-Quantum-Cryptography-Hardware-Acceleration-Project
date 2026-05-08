// main.c - bare-metal compatible HQC-KEM test using PQClean
#include <stdint.h>
#include <stddef.h>
#include "api_unified.h"
#include "hqc_1_128/shake_prng.h"
#include "randombytes.h"
#include "uart_print.h"
#include "cycle_counter.h"
#include "config_helpers.h"
#include "custom_string.h"


int main(void) {
    // ALLOCATE MAX SIZES (HQC-256)
    static uint8_t pk[PQCLEAN_HQC256_CLEAN_CRYPTO_PUBLICKEYBYTES];
    static uint8_t sk[PQCLEAN_HQC256_CLEAN_CRYPTO_SECRETKEYBYTES];
    static uint8_t ct[PQCLEAN_HQC256_CLEAN_CRYPTO_CIPHERTEXTBYTES];
    static uint8_t key_enc[PQCLEAN_HQC256_CLEAN_CRYPTO_BYTES];
    static uint8_t key_dec[PQCLEAN_HQC256_CLEAN_CRYPTO_BYTES];
    uint8_t seed[32];

    //uint64_t startCycle, endCycle;

    while (1) {
        uart_puts("\n==================================\n");
        uart_puts("Select HQC Security Level:\n");
        uart_puts("1: HQC-128\n");
        uart_puts("3: HQC-192\n");
        uart_puts("5: HQC-256\n");
        uart_puts("Waiting for input...\n");

        char choice;
        while (1) {
            choice = uart_getc();
            
            if (choice == '1' || choice == '3' || choice == '5') {
                break; 
            }
            
            if (choice != '\r' && choice != '\n' && choice != '\0') {
                uart_puts("\nInvalid choice. Please select 1, 3, or 5.\n");
            }
        }

        // Reset stack high-water mark for measurement per run
        stack_paint();

        // Variables to hold the current sizes for printing later
        size_t pk_size, sk_size, ct_size, key_size;

        // Initialize RNG for the run
        init_seed(seed, sizeof(seed));
        init_randombytes(seed, sizeof(seed));

        // EXECUTE SELECTED LEVEL
        if (choice == '1') {
            choice = '0';
            uart_puts("\n--- Running HQC-128 ---\n");               //startCycle = read_cycles();
            PQCLEAN_HQC128_CLEAN_crypto_kem_keypair(pk, sk);        //endCycle = read_cycles(); uart_puts("\nKeygen: "); uart_putint(endCycle - startCycle); startCycle = read_cycles();
            PQCLEAN_HQC128_CLEAN_crypto_kem_enc(ct, key_enc, pk);   //endCycle = read_cycles(); uart_puts("\nEncaps: "); uart_putint(endCycle - startCycle); startCycle = read_cycles();
            PQCLEAN_HQC128_CLEAN_crypto_kem_dec(key_dec, ct, sk);   //endCycle = read_cycles(); uart_puts("\nDecaps: "); uart_putint(endCycle - startCycle);

            pk_size = PQCLEAN_HQC128_CLEAN_CRYPTO_PUBLICKEYBYTES;
            sk_size = PQCLEAN_HQC128_CLEAN_CRYPTO_SECRETKEYBYTES;
            ct_size = PQCLEAN_HQC128_CLEAN_CRYPTO_CIPHERTEXTBYTES;
            key_size = PQCLEAN_HQC128_CLEAN_CRYPTO_BYTES;

        } else if (choice == '3') {
            choice = '0';
            uart_puts("\n--- Running HQC-192 ---\n");               //startCycle = read_cycles();
            PQCLEAN_HQC192_CLEAN_crypto_kem_keypair(pk, sk);        //endCycle = read_cycles(); uart_puts("\nKeygen: "); uart_putint(endCycle - startCycle); startCycle = read_cycles();
            PQCLEAN_HQC192_CLEAN_crypto_kem_enc(ct, key_enc, pk);   //endCycle = read_cycles(); uart_puts("\nEncaps: "); uart_putint(endCycle - startCycle); startCycle = read_cycles(); 
            PQCLEAN_HQC192_CLEAN_crypto_kem_dec(key_dec, ct, sk);   //endCycle = read_cycles(); uart_puts("\nDecaps: "); uart_putint(endCycle - startCycle);

            pk_size = PQCLEAN_HQC192_CLEAN_CRYPTO_PUBLICKEYBYTES;
            sk_size = PQCLEAN_HQC192_CLEAN_CRYPTO_SECRETKEYBYTES;
            ct_size = PQCLEAN_HQC192_CLEAN_CRYPTO_CIPHERTEXTBYTES;
            key_size = PQCLEAN_HQC192_CLEAN_CRYPTO_BYTES;

        } else if (choice == '5') {
            choice = '0';
            uart_puts("\n--- Running HQC-256 ---\n");               //startCycle = read_cycles();
            PQCLEAN_HQC256_CLEAN_crypto_kem_keypair(pk, sk);        //endCycle = read_cycles(); uart_puts("\nKeygen: "); uart_putint(endCycle - startCycle); startCycle = read_cycles();
            PQCLEAN_HQC256_CLEAN_crypto_kem_enc(ct, key_enc, pk);   //endCycle = read_cycles(); uart_puts("\nEncaps: "); uart_putint(endCycle - startCycle); startCycle = read_cycles(); 
            PQCLEAN_HQC256_CLEAN_crypto_kem_dec(key_dec, ct, sk);   //endCycle = read_cycles(); uart_puts("\nDecaps: "); uart_putint(endCycle - startCycle);

            pk_size = PQCLEAN_HQC256_CLEAN_CRYPTO_PUBLICKEYBYTES;
            sk_size = PQCLEAN_HQC256_CLEAN_CRYPTO_SECRETKEYBYTES;
            ct_size = PQCLEAN_HQC256_CLEAN_CRYPTO_CIPHERTEXTBYTES;
            key_size = PQCLEAN_HQC256_CLEAN_CRYPTO_BYTES;

        } else {
            choice = '0';
            uart_puts("\nInvalid choice. Please select 1, 3, or 5.\n");
            continue;
        }

        // PRINT OUTPUTS
        #ifndef PC_TEST
            uart_puthex_array("\n\npk", pk, pk_size);
            uart_puts("\n");
            uart_puthex_array("sk", sk, sk_size);
            uart_puts("\n");
            uart_puthex_array("ct", ct, ct_size);
            uart_puts("\n");
            uart_puthex_array("key_enc", key_enc, key_size);
            uart_puts("\n");
            uart_puthex_array("key_dec", key_dec, key_size);
            uart_puts("\n");
        #endif

        #ifdef PC_TEST
            print_hex_pc_test("pk", pk, pk_size);
            print_hex_pc_test("sk", sk, sk_size);
            print_hex_pc_test("ct", ct, ct_size);
            print_hex_pc_test("key_enc", key_enc, key_size);
            print_hex_pc_test("key_dec", key_dec, key_size);
        #endif

        // STACK USAGE AND CLEANUP
        #ifndef PC_TEST
            size_t stackUsage = get_stack_usage_bytes();
            uart_puts("Stack usage: ");
            uart_puthex((uint32_t)stackUsage);
            uart_putc('\n');
        #endif

        // Zeroize sensitive data based on the current level's sizes
        memset_zero(sk, sk_size);
        memset_zero(key_enc, key_size);
        memset_zero(key_dec, key_size);
        memset_zero(seed, sizeof(seed));
    }
    return 0;
}