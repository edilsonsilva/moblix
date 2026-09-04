const route = require("express").Router();
const conexao = require("../database/config.js")



route.post("/insert",(req,res)=>{
    conexao.query(`INSERT INTO instituicoes SET ?`,req.body,(error,result)=>{
        if(error){
        return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a instituição -> ${error}`});
    }
    return res.status(201).send({flag:`OK`,payload:result})
    })
});

route.get("/list",(req,res)  =>{
    conexao.query(`SELECT * FROM instituicoes`,(error,result)=>{
        if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a instituição -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,payload:result});
    });
})

route.get("/list_id/:id",(req,res)=>{
    conexao.query(`SELECT * FROM instituicoes WHERE id=?`,req.params.id,(error,result)=>{
if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a instituição -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,payload:result});
    });
})

route.get("/list_cnpj/:cnpj",(req,res)=>{
    conexao.query(`SELECT * FROM instituicoes WHERE cnpj=?`,req.params.cnpj,(error,result)=>{
if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a instituição -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,payload:result});
    });
})

route.get("/list_tipo/:tipo",(req,res)=>{
    conexao.query(`SELECT * FROM instituicoes WHERE tipo=?`,req.params.tipo,(error,result)=>{
if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a instituição -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,payload:result});
    });
})

route.get("/list_nome/:nome",(req,res)=>{
    const q = `%${req.params.nome}%`
    conexao.query(`SELECT * FROM instituicoes WHERE nome LIKE ?`,q,(error,result)=>{
if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao cadastrar a instituição -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,payload:result});
    });
})
route.put("/update/:id",(req,res)=>{
    conexao.query(`UPDATE instituicoes SET ? WHERE id = ?`,[req.body, req.params.id],(error,result)=>{
        if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao tentar atualizar os dados da instituição -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,playload:result})
    })
})
//Comparação entre Instituições
route.get("/parativos",(req,res)=>{
    const sql = `SELECT 
    inst.nome AS Instituicao,
    inst.tipo AS Tipo_Ensino,
    
    -- Indicadores de Volume
    COUNT(pat.id) AS Total_Equipamentos,
    
    -- Indicadores Financeiros
    COALESCE(SUM(pat.valor_aquisicao), 0) AS Valor_Total_Patrimonio,
    COALESCE(AVG(pat.valor_aquisicao), 0) AS Valor_Medio_Equipamento,
    
    -- Distribuição por Status (Pivot)
    SUM(CASE WHEN pat.status = 'Disponível' THEN 1 ELSE 0 END) AS Qtd_Disponivel,
    SUM(CASE WHEN pat.status = 'Emprestado' THEN 1 ELSE 0 END) AS Qtd_Emprestado,
    SUM(CASE WHEN pat.status = 'Em Manutenção' THEN 1 ELSE 0 END) AS Qtd_Manutencao,
    SUM(CASE WHEN pat.status = 'Baixado/Inativo' THEN 1 ELSE 0 END) AS Qtd_Baixados

FROM 
    instituicoes inst
LEFT JOIN 
    patrimonios pat ON inst.id = pat.instituicao_id
GROUP BY 
    inst.id, 
    inst.nome, 
    inst.tipo
ORDER BY 
    Valor_Total_Patrimonio DESC;`
    conexao.query(sql,(error,result)=>{
        if(error){
            return res.status(500).send({flag:`Error`,msg:`Erro ao tentar comparar os dados da instituição -> ${error}`});
        }
        return res.status(200).send({flag:`OK`,playload:result})
    })
})






module.exports = route;