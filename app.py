import streamlit as st
import subprocess
import os
import time

st.set_page_config(page_title="LEVIATHAN COBOL", page_icon="🏛️", layout="wide")

st.markdown("""
    <style>
    .footer { position: fixed; left: 0; bottom: 0; width: 100%; background-color: #0e1117; color: white; text-align: center; padding: 15px 0; border-top: 1px solid #4a4a4a; z-index: 999; }
    .footer a { color: #d4af37; text-decoration: none; margin: 0 15px; font-size: 20px; transition: 0.3s; }
    .footer a:hover { color: #ffffff; text-shadow: 0 0 10px #d4af37; }
    </style>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    """, unsafe_allow_html=True)

st.title("🏛️ LEVIATHAN: Core Banking Settlement Engine")
st.markdown("##### *Mainframe batch processing and exact decimal arithmetic powered by COBOL.*")
st.divider()

if st.button("⚙️ Execute End-of-Day (EOD) Batch Process", type="primary"):
    
    os.makedirs('cobol_engine', exist_ok=True)
    os.makedirs('data/output', exist_ok=True)
    
    with st.spinner("Compiling COBOL Source to Native Mainframe Binary..."):
        try:
            # استخدام GnuCOBOL لترجمة الكود (بصيغة Free Format)
            subprocess.run(["cobc", "-x", "-free", "-o", "cobol_engine/leviathan", "src/leviathan_core.cbl"], check=True)
        except FileNotFoundError:
            st.warning("⚠️ Local GnuCOBOL Compiler Missing. Deploy to Streamlit Cloud to run this!")
            st.stop()
            
    start_time = time.time()
    with st.spinner("Processing 50,000 ledger transactions..."):
        subprocess.run(["./cobol_engine/leviathan"])
    end_time = time.time()
    
    st.success(f"✅ Batch processing completed successfully in {end_time - start_time:.4f} seconds!")
    
    try:
        with open('data/output/settlement_report.txt', 'r', encoding='utf-8') as f:
            st.code(f.read(), language="text")
    except FileNotFoundError:
        st.warning("Execution failed. No report generated.")
        
    st.info("💡 **Architectural Note:** Notice the monetary totals in the report? COBOL uses `COMP-3` (Packed-Decimal) encoding, completely eliminating the floating-point errors common in Python, Java, or C++. This is why the world's wealth still rests on COBOL.")

st.markdown("""
    <div class="footer">
        <a href="https://github.com/ubaydaali" target="_blank"><i class="fab fa-github"></i></a>
        <a href="https://www.linkedin.com/in/ubayda-ali-95972a406/" target="_blank"><i class="fab fa-linkedin"></i></a>
        <a href="https://t.me/obedaale" target="_blank"><i class="fab fa-telegram"></i></a>
        <a href="https://onws.net" target="_blank"><i class="fas fa-globe"></i></a>
        <br><span style="font-size:12px; color:#888;">Executive Architect: UBAYDA ALİ | Engineered with COBOL & Python</span>
    </div>
    """, unsafe_allow_html=True)
